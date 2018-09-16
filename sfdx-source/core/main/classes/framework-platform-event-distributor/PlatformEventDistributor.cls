public class PlatformEventDistributor
{
    private enum MatcherRules
    {
        MatchPlatformEventBusAndRelatedSObjectAndEventName,
        MatchPlatformEventBusAndRelatedSObject,
        MatchPlatformEventBusandEventName,
        MatchPlatformEventBus
    }

    private Map<String, List<PlatformEvents_Distribution__mdt>> eventBusToConfigurationMap = new Map<String, List<PlatformEvents_Distribution__mdt>>();

    public PlatformEventDistributor()
    {
        Map<String, List<PlatformEvents_Distribution__mdt>> eventBusToConfigurationMap = new Map<String, List<PlatformEvents_Distribution__mdt>>();

        for (
            di_Binding binding
            :
            di_Injector.Org.Bindings
                .byName(IEventsConsumer.class.getName())
                .get()
        )
        {
            PlatformEvents_Distribution__mdt pedConfig = (PlatformEvents_Distribution__mdt) binding.Data;

            if (!eventBusToConfigurationMap.containsKey(pedConfig.RelatedPlatformEventBus__c))
            {
                eventBusToConfigurationMap.put(pedConfig.RelatedPlatformEventBus__c, new List<PlatformEvents_Distribution__mdt>());
            }

            eventBusToConfigurationMap.get(pedConfig.RelatedPlatformEventBus__c).add(pedConfig);
        }
    }

    public static void triggerHandler()
    {
        if (Trigger.isExecuting&& Trigger.isAfter&& Trigger.isInsert)
        {
            triggerHandler( trigger.new );
        }
    }

    @TestVisible
    private static void triggerHandler(List<SObject> events)
    {
    //     System.debug('<ojs> events:\n' + events);

    //     if (events != null && ! events.isEmpty())
    //     {
    //         // extract the event payloads
    //         Set<String> eventNameSet = Utils.generateStringSetFromField( events, Event__e.EventName__c );
    //         Set<String> relatedSObjectSet = Utils.generateStringSetFromField( events, Event__e.RelatedSObject__c );

    //         Schema.DescribeSObjectResult platformEventBusDescribe = events.getSobjectType().getDescribe();

    //         // need to read all available EventConsumerSubscription__mdt records for this event SObjectType
    //         // SOQL targeting custom MDT tables does not support the OR operator.  Manually filter.
    //         // https://help.salesforce.com/articleView?id=custommetadatatypes_limitations.htm
    //         List<EventConsumerSubscription__mdt> subscriptionRecords = new List<EventConsumerSubscription__mdt>();
    //         for
    //         (
    //             EventConsumerSubscription__mdt ecs :
    //             [
    //                 select
    //                     Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label
    //                     , QualifiedApiName, Consumer__c, EventSObjectCategory__c, Event__c
    //                     , IsActive__c, MatcherRule__c, RelatedPlatformEventBus__c 
    //                 from EventConsumerSubscription__mdt
    //                 where IsActive__c = true and RelatedPlatformEventBus__c = :platformEventBusDescribe.getName()
    //             ]
    //         )
    //         {
    //             if (relatedSObjectSet.contains(ecs.EventSObjectCategory__c) || eventNameSet.contains(ecs.Event__c))
    //             {
    //                 subscriptionRecords.add(ecs);
    //             }
    //         }

    //         System.debug('<ojs> subscriptionRecords:\n' + subscriptionRecords);

    //         IEventsConsumer consumer = null;

    //         List<SObject> eventBatchForSubscriber = new List<SObject>();

    //         Set<String> platformEventBusAvailableFieldsSet = platformEventBusDescribe.fields.getMap().keyset();

    //         // for each EventConsumerSubscription__mdt record, instantiate the Apex class found in the Consumer field
    //         for ( EventConsumerSubscription__mdt subscriptionRecord : subscriptionRecords )
    //         {
    //             eventBatchForSubscriber.clear();

    //             // sort through the events and only select the ones that this subscriber is interested.
    //             for ( SObject event : events )
    //             {
    //                 System.debug(
    //                     '<ojs> Comparing ...\n' +
    //                     'platformEventBusDescribe:\n\t' + platformEventBusDescribe + '\n' +
    //                     'platformEventBusDescribe.getName():\n\t' + platformEventBusDescribe.getName() + '\n' +
    //                     'subscriptionRecord:\n\t' + subscriptionRecord + '\n' +
    //                     'event:\n\t' + event);

    //                 // Match on RelatedSObject__c and EventName__c
    //                 if ( platformEventBusDescribe.getName().equalsIgnoreCase( subscriptionRecord.RelatedPlatformEventBus__c )
    //                     && MatcherRules.MatchPlatformEventBusAndRelatedSObjectAndEventName.name().equalsIgnoreCase( subscriptionRecord.MatcherRule__c )
    //                     && platformEventBusAvailableFieldsSet.contains( RELATED_SOBJECT_FIELD_NAME )
    //                     && platformEventBusAvailableFieldsSet.contains( EVENT_NAME_FIELD_NAME )
    //                     && subscriptionRecord.EventSObjectCategory__c.equalsIgnoreCase( (String)event.get( RELATED_SOBJECT_FIELD_NAME ) )
    //                     && subscriptionRecord.Event__c.equalsIgnoreCase( (String)event.get( EVENT_NAME_FIELD_NAME ) ) )
    //                 {
    //                     System.debug('<ojs> match #1');
    //                     eventBatchForSubscriber.add( event );
    //                 }
    //                 // Match on RelatedSObject__c
    //                 else if ( platformEventBusDescribe.getName().equalsIgnoreCase( subscriptionRecord.RelatedPlatformEventBus__c )
    //                     && MatcherRules.MatchPlatformEventBusAndRelatedSObject.name().equalsIgnoreCase( subscriptionRecord.MatcherRule__c )
    //                     && platformEventBusAvailableFieldsSet.contains( RELATED_SOBJECT_FIELD_NAME )
    //                     && subscriptionRecord.EventSObjectCategory__c.equalsIgnoreCase( (String)event.get( RELATED_SOBJECT_FIELD_NAME ) ) )
    //                 {
    //                     System.debug('<ojs> match #2');
    //                     eventBatchForSubscriber.add( event );
    //                 }
    //                 // Match on EventName__c
    //                 else if ( platformEventBusDescribe.getName().equalsIgnoreCase( subscriptionRecord.RelatedPlatformEventBus__c )
    //                     && MatcherRules.MatchPlatformEventBusandEventName.name().equalsIgnoreCase( subscriptionRecord.MatcherRule__c )
    //                     && platformEventBusAvailableFieldsSet.contains( EVENT_NAME_FIELD_NAME )
    //                     && subscriptionRecord.Event__c.equalsIgnoreCase( (String)event.get( EVENT_NAME_FIELD_NAME ) ) )
    //                 {
    //                     System.debug('<ojs> match #3');
    //                     eventBatchForSubscriber.add( event );
    //                 }
    //                 // Match sole because it is an event on this specific platform event bus
    //                 else if ( platformEventBusDescribe.getName().equalsIgnoreCase( subscriptionRecord.RelatedPlatformEventBus__c )
    //                     && MatcherRules.MatchPlatformEventBusOnly.name().equalsIgnoreCase( subscriptionRecord.MatcherRule__c ) )
    //                 {
    //                     System.debug('<ojs> match #4');
    //                     eventBatchForSubscriber.add( event );
    //                 }
    //                 else
    //                 {
    //                     System.debug('<ojs> no match');
    //                 }
    //             }

    //             System.debug('<ojs> eventBatchForSubscriber:\n' + eventBatchForSubscriber);

    //             if ( ! eventBatchForSubscriber.isEmpty() )
    //             {
    //                 // now that the events have been sorted for this specific subscription, distribute them to that subscriber
    //                 try 
    //                 {
    //                     System.debug('<ojs> attempting to construct the consumer');
    //                     System.debug('<ojs> subscriptionRecord.Consumer__c:\n' + subscriptionRecord.Consumer__c);

    //                     // verify that the class exists and that class implements the IEventsConsumer interface
    //                     consumer = (IEventsConsumer)(Type.forName( subscriptionRecord.Consumer__c ).newInstance());

    //                     System.debug('<ojs> successfully constructed');

    //                     // use the setEvents() method to set the payload
    //                     consumer.setEvents( eventBatchForSubscriber );

    //                     //  and then enqueue the consumer class 
    //                     Id jobId = System.enqueueJob( consumer );

    //                     System.debug('<ojs> job enqueued: ' + jobId);
    //                 }
    //                 catch (Exception e)
    //                 {
    //                     system.debug( e );
    //                     System.debug( subscriptionRecord );
    //                     System.debug( eventBatchForSubscriber );
    //                 }
    //             }
    //         }
    //     }
    }
}
