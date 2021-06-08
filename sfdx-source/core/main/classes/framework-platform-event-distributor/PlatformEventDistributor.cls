/**
 * Copyright (c) 2021, John M. Daniel & John Storey
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
    private enum MATCHER_RULES
    {
        MatchEventBusAndCategoryAndEventName,
        MatchEventBusAndCategory,
        MatchEventBusAndEventName,
        MatchEventBus
    }

    private static final String CATEGORY_FIELD_NAME = 'Category__c'.toLowerCase();
    private static final String EVENT_NAME_FIELD_NAME = 'EventName__c'.toLowerCase();

    @TestVisible
    private List<Id> jobIdList = new List<Id>();

    // This method retrieves the platform event subscriptions for a given event bus from the force-di cache
    private List<PlatformEvents_Subscription__mdt> getRegisteredSubscribers(Schema.SObjectType sobjType)
    {
        List<PlatformEvents_Subscription__mdt> platformEventSubscriptions = new List<PlatformEvents_Subscription__mdt>();

        List<di_Binding> bindings = di_Injector.Org.Bindings.byName(IEventsConsumer.class.getName()).bySObject(sobjType).get();

        for (di_Binding binding : bindings)
        {
            PlatformEvents_Subscription__mdt platformEventSubscription = (PlatformEvents_Subscription__mdt) binding.Data;

            platformEventSubscriptions.add(platformEventSubscription);
        }

        return platformEventSubscriptions;
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
        if (events == null || events.isEmpty()) { return; }

        // Describe schema associated with the platform event
        Schema.SObjectType platformEventBus = events.getSObjectType();
        Schema.DescribeSObjectResult platformEventBusDescribe = platformEventBus.getDescribe();
        Schema.SObjectField categoryField = platformEventBusDescribe.fields.getMap().get(CATEGORY_FIELD_NAME);
        Schema.SObjectField eventNameField = platformEventBusDescribe.fields.getMap().get(EVENT_NAME_FIELD_NAME);

        // Perform a simple check to verify the PE conforms to the object shape
        if (categoryField == null || eventNameField == null) {
            throw new PlatformEventDistributorException('Platform Event must implement the Category and Event Name fields');
        }

        // Extract the Category and Event Name values from the events for matching purposes
        Set<String> eventCategorySet = generateStringSetFromFieldValues(events, categoryField, false);
        Set<String> eventNameSet = generateStringSetFromFieldValues(events, eventNameField, false);

        // We need to retrieve the platform event subscriptions from the force-di cache for the relevant event bus
        // Then we need to manually filter for EventCategory and Event values
        // This filtering helps our nested loops below process quicker, by exlcuding subscriptions that NO subscribers are looking for
        List<PlatformEvents_Subscription__mdt> applicableEventSubscriptionRecords = new List<PlatformEvents_Subscription__mdt>();
        for (PlatformEvents_Subscription__mdt platformEventSubscription : getRegisteredSubscribers(platformEventBus))
        {
            if (eventCategorySet.contains(platformEventSubscription.EventCategory__c) || eventNameSet.contains(platformEventSubscription.Event__c))
            {
                applicableEventSubscriptionRecords.add(platformEventSubscription);
            }
        }

        Set<String> platformEventBusAvailableFieldsSet = platformEventBusDescribe.fields.getMap().keyset();

        // For each Platform Events Subscription, we iterate over the events and instantiate the apex class found in the Consumer field for interested subscribers
        for ( PlatformEvents_Subscription__mdt subscriptionRecord : applicableEventSubscriptionRecords )
        {
            IEventsConsumer consumer = null;

            // This is the running list of events this subscriber is interested in based on the filtering criteria
            List<SObject> eventBatchForSubscriber = new List<SObject>();

            // Sort through the events and only select the ones that this subscriber is interested.
            for ( SObject event : events )
            {
                // Match on Category__c and EventName__c
                if ( platformEventBusDescribe.getName().equalsIgnoreCase( subscriptionRecord.EventBus__c )
                    && MATCHER_RULES.MatchEventBusAndCategoryAndEventName.name().equalsIgnoreCase( subscriptionRecord.MatcherRule__c )
                    && platformEventBusAvailableFieldsSet.contains( CATEGORY_FIELD_NAME )
                    && platformEventBusAvailableFieldsSet.contains( EVENT_NAME_FIELD_NAME )
                    && subscriptionRecord.EventCategory__c.equalsIgnoreCase( (String)event.get( CATEGORY_FIELD_NAME ) )
                    && subscriptionRecord.Event__c.equalsIgnoreCase( (String)event.get( EVENT_NAME_FIELD_NAME ) ) )
                {
                    System.debug('Subscriber Match on Category__c and EventName__c');
                    eventBatchForSubscriber.add( event );
                }

                // Match on Category__c
                else if ( platformEventBusDescribe.getName().equalsIgnoreCase( subscriptionRecord.EventBus__c )
                    && MATCHER_RULES.MatchEventBusAndCategory.name().equalsIgnoreCase( subscriptionRecord.MatcherRule__c )
                    && platformEventBusAvailableFieldsSet.contains( CATEGORY_FIELD_NAME )
                    && subscriptionRecord.EventCategory__c.equalsIgnoreCase( (String)event.get( CATEGORY_FIELD_NAME ) ) )
                {
                    System.debug('Subscriber Match on Category__c');
                    eventBatchForSubscriber.add( event );
                }

                // Match on EventName__c
                else if ( platformEventBusDescribe.getName().equalsIgnoreCase( subscriptionRecord.EventBus__c )
                    && MATCHER_RULES.MatchEventBusAndEventName.name().equalsIgnoreCase( subscriptionRecord.MatcherRule__c )
                    && platformEventBusAvailableFieldsSet.contains( EVENT_NAME_FIELD_NAME )
                    && subscriptionRecord.Event__c.equalsIgnoreCase( (String)event.get( EVENT_NAME_FIELD_NAME ) ) )
                {
                    System.debug('Subscriber Match on EventName__c');
                    eventBatchForSubscriber.add( event );
                }

                // Match on EventBus__c
                else if ( platformEventBusDescribe.getName().equalsIgnoreCase( subscriptionRecord.EventBus__c )
                    && MATCHER_RULES.MatchEventBus.name().equalsIgnoreCase( subscriptionRecord.MatcherRule__c ) )
                {
                    System.debug('Subscriber Match on EventBus__c');
                    eventBatchForSubscriber.add( event );
                }

                else
                {
                    // This should never happen
                    // TODO: Validate that this never occurs due to the force-di filtering that occurs previous to the manual filtering
                    System.debug('Subscriber did not match this event');
                }
            }

            System.debug('eventBatchForSubscriber:\n' + eventBatchForSubscriber);

            if ( ! eventBatchForSubscriber.isEmpty() )
            {
                // Now that the events have been sorted for this specific subscription, distribute them to that subscriber
                try
                {
                    System.debug('Attempting to construct the consumer');
                    System.debug('SubscriptionRecord.Consumer__c: ' + subscriptionRecord.Consumer__c);

                    // Verify that the class exists and that class implements the IEventsConsumer interface
                    consumer = (IEventsConsumer) (Type.forName( subscriptionRecord.Consumer__c ).newInstance());

                    System.debug('Successfully constructed');

                    // If the subscriber wishes to be executed asyncronously, assign the job id
                    Id thisJob = subscriptionRecord.Execute_Synchronous__c != null && subscriptionRecord.Execute_Synchronous__c
                        ? consumer.setEvents(eventBatchForSubscriber).setRunSynchronous().run()
                        : consumer.setEvents(eventBatchForSubscriber).run();
                    
                    // If the subscriber was executed asyncronously, store the job id
                    if (thisJob != null) {
                        jobIdList.add( thisJob );
                    }

                }
                catch (Exception ex)
                {
                    System.debug( ex );
                    System.debug( subscriptionRecord );
                    System.debug( eventBatchForSubscriber );
                }
            }
        }

        System.debug('jobIdList: ' + jobIdList);
    }

    private static Set<String> generateStringSetFromFieldValues(List<SObject> sobjList, SObjectField sobjField, Boolean includeBlankValues)
    {
        Set<String> result = new Set<String>();

        if (sobjList == null || sobjList.isEmpty()) { return result; }
        if (sobjField == null) { return result; }

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

    public class PlatformEventDistributorException
        extends Exception
    {
        // Intentionally blank
    }
}
