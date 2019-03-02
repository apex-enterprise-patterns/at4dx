/**
 * Copyright (c) 2018, John M. Daniel
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, 
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, 
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, 
 *      this list of conditions and the following disclaimer in the documentation 
 *      and/or other materials provided with the distribution.
 * - Neither the name of the John M. Daniel, nor the names of its contributors 
 *      may be used to endorse or promote products derived from this software without 
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/

public class PlatformEventDistributor
{
    private enum MatcherRules
    {
        MatchEventBusAndCategoryAndEventName,
        MatchEventBusAndCategory,
        MatchEventBusAndEventName,
        MatchEventBus
    }

    private static string CATEGORY_FIELD_NAME = 'Category__c'.toLowerCase();
    private static string EVENT_NAME_FIELD_NAME = 'EventName__c'.toLowerCase();

    private Map<String, List<PlatformEvents_Subscription__mdt>> eventBusToConfigurationMap = new Map<String, List<PlatformEvents_Subscription__mdt>>();

    @TestVisible
    private List<Id> jobIdList = new List<Id>();

    public PlatformEventDistributor()
    {
        Map<String, List<PlatformEvents_Subscription__mdt>> eventBusToConfigurationMap = new Map<String, List<PlatformEvents_Subscription__mdt>>();

        list<di_Binding> bindings = di_Injector.Org.Bindings.byName(IEventsConsumer.class.getName()).get();

        for (di_Binding binding : bindings)
        {
            PlatformEvents_Subscription__mdt pedConfig = (PlatformEvents_Subscription__mdt) binding.Data;

            if (!eventBusToConfigurationMap.containsKey(pedConfig.EventBus__c))
            {
                eventBusToConfigurationMap.put(pedConfig.EventBus__c, new List<PlatformEvents_Subscription__mdt>());
            }

            eventBusToConfigurationMap.get(pedConfig.EventBus__c).add(pedConfig);

            System.debug(eventBusToConfigurationMap);
        }
    }

    public static void triggerHandler()
    {
        if (Trigger.isExecuting && Trigger.isAfter && Trigger.isInsert)
        {
            new PlatformEventDistributor().triggerHandler(trigger.new);
        }
    }

    @TestVisible
    private void triggerHandler(List<SObject> events)
    {
        System.debug('events:\n' + events);

        if (events == null || events.isEmpty()) return;

        // extract the event payloads
        Set<String> eventNameSet = generateStringSetFromField(events, Event__e.EventName__c, false);
        Set<String> eventCategorySet = generateStringSetFromField(events, Event__e.Category__c, false);

        Schema.DescribeSObjectResult platformEventBusDescribe = events.getSobjectType().getDescribe();

        // need to read all available PlatformEvents_Subscription__mdt records for this event SObjectType
        // SOQL targeting custom MDT tables does not support the OR operator.  Manually filter.
        // https://help.salesforce.com/articleView?id=custommetadatatypes_limitations.htm
        List<PlatformEvents_Subscription__mdt> eventSubscriptionRecords = new List<PlatformEvents_Subscription__mdt>();
        for
        (
            PlatformEvents_Subscription__mdt ped :
            [
                select
                    Consumer__c, EventCategory__c, Event__c, IsActive__c, MatcherRule__c, EventBus__c, Execute_Synchronous__c
                from PlatformEvents_Subscription__mdt
                where IsActive__c = true AND EventBus__c = :platformEventBusDescribe.getName()
            ]
        )
        {
            if (eventCategorySet.contains(ped.EventCategory__c) || eventNameSet.contains(ped.Event__c))
            {
                eventSubscriptionRecords.add(ped);
            }
        }

        System.debug(
            '\neventNameSet:\n\t' + eventNameSet + '\n' +
            'eventCategorySet:\n\t' + eventCategorySet + '\n' +
            'CMDT records:\n\t' + [select Consumer__c, EventCategory__c, Event__c, IsActive__c, MatcherRule__c, EventBus__c from PlatformEvents_Subscription__mdt] + '\n' +
            'Event bus name: ' + platformEventBusDescribe.getName() + '\n' +
            'eventSubscriptionRecords:\n\t' + eventSubscriptionRecords);

        IEventsConsumer consumer = null;

        List<SObject> eventBatchForSubscriber = new List<SObject>();

        Set<String> platformEventBusAvailableFieldsSet = platformEventBusDescribe.fields.getMap().keyset();

        // for each PlatformEvents_Subscription__mdt record, instantiate the Apex class found in the Consumer field
        for ( PlatformEvents_Subscription__mdt subscriptionRecord : eventSubscriptionRecords )
        {
            eventBatchForSubscriber.clear();

            // sort through the events and only select the ones that this subscriber is interested.
            for ( SObject event : events )
            {
                System.debug(
                    'Comparing ...\n' +
                    'platformEventBusAvailableFieldsSet:\n\t' + new List<String>(platformEventBusAvailableFieldsSet) + '\n' +
                    'platformEventBusDescribe.getName(): ' + platformEventBusDescribe.getName() + '\n' +
                    'subscriptionRecord:\n\t' + subscriptionRecord + '\n' +
                    'event:\n\t' + event);

                // Match on Category__c and EventName__c
                if ( platformEventBusDescribe.getName().equalsIgnoreCase( subscriptionRecord.EventBus__c )
                    && MatcherRules.MatchEventBusAndCategoryAndEventName.name().equalsIgnoreCase( subscriptionRecord.MatcherRule__c )
                    && platformEventBusAvailableFieldsSet.contains( CATEGORY_FIELD_NAME )
                    && platformEventBusAvailableFieldsSet.contains( EVENT_NAME_FIELD_NAME )
                    && subscriptionRecord.EventCategory__c.equalsIgnoreCase( (String)event.get( CATEGORY_FIELD_NAME ) )
                    && subscriptionRecord.Event__c.equalsIgnoreCase( (String)event.get( EVENT_NAME_FIELD_NAME ) ) )
                {
                    System.debug('<ojs> match #1');
                    eventBatchForSubscriber.add( event );
                }

                // Match on Category__c
                else if ( platformEventBusDescribe.getName().equalsIgnoreCase( subscriptionRecord.EventBus__c )
                    && MatcherRules.MatchEventBusAndCategory.name().equalsIgnoreCase( subscriptionRecord.MatcherRule__c )
                    && platformEventBusAvailableFieldsSet.contains( CATEGORY_FIELD_NAME )
                    && subscriptionRecord.EventCategory__c.equalsIgnoreCase( (String)event.get( CATEGORY_FIELD_NAME ) ) )
                {
                    System.debug('<ojs> match #2');
                    eventBatchForSubscriber.add( event );
                }

                // Match on EventName__c
                else if ( platformEventBusDescribe.getName().equalsIgnoreCase( subscriptionRecord.EventBus__c )
                    && MatcherRules.MatchEventBusandEventName.name().equalsIgnoreCase( subscriptionRecord.MatcherRule__c )
                    && platformEventBusAvailableFieldsSet.contains( EVENT_NAME_FIELD_NAME )
                    && subscriptionRecord.Event__c.equalsIgnoreCase( (String)event.get( EVENT_NAME_FIELD_NAME ) ) )
                {
                    System.debug('<ojs> match #3');
                    eventBatchForSubscriber.add( event );
                }

                // Match sole because it is an event on this specific platform event bus
                else if ( platformEventBusDescribe.getName().equalsIgnoreCase( subscriptionRecord.EventBus__c )
                    && MatcherRules.MatchEventBus.name().equalsIgnoreCase( subscriptionRecord.MatcherRule__c ) )
                {
                    System.debug('<ojs> match #4');
                    eventBatchForSubscriber.add( event );
                }

                else
                {
                    System.debug('<ojs> no match');
                }
            }

            System.debug('<ojs> eventBatchForSubscriber:\n' + eventBatchForSubscriber);

            if ( ! eventBatchForSubscriber.isEmpty() )
            {
                // now that the events have been sorted for this specific subscription, distribute them to that subscriber
                try
                {
                    System.debug('<ojs> attempting to construct the consumer');
                    System.debug('<ojs> subscriptionRecord.Consumer__c:\n' + subscriptionRecord.Consumer__c);

                    // verify that the class exists and that class implements the IEventsConsumer interface
                    consumer = (IEventsConsumer)(Type.forName( subscriptionRecord.Consumer__c ).newInstance());

                    System.debug('<ojs> successfully constructed');

                    Id thisJob = subscriptionRecord.Execute_Synchronous__c != null && subscriptionRecord.Execute_Synchronous__c
                        ? consumer.setEvents(eventBatchForSubscriber).setRunSynchronous().run()
                        : consumer.setEvents(eventBatchForSubscriber).run();
                    
                    if (thisJob != null) {
                        jobIdList.add( thisJob );
                    }

                }
                catch (Exception e)
                {
                    system.debug( e );
                    System.debug( subscriptionRecord );
                    System.debug( eventBatchForSubscriber );
                }
            }
        }

        System.debug('<ojs> jobIdList: ' + jobIdList);
    }

    private static Set<String> generateStringSetFromField(List<SObject> sobjList, SObjectField sobjField, Boolean includeBlankValues)
    {
        Set<String> result = new Set<String>();

        if (sobjList == null || sobjList.isEmpty()) return result;
        if (sobjField == null) return result;

        for (SObject sobj : sobjList)
        {
            String value = (String) sobj.get(sobjField);
            if (String.isNotBlank(value) || (String.isBlank(value) && includeBlankValues))
            {
                result.add(value);
            }
        }

        return result;
    }
}
