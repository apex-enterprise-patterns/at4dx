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

        for (di_Binding binding : di_Injector.Org.Bindings.byName(IEventsConsumer.class.getName()).get())
        {
            PlatformEvents_Distribution__mdt pedConfig = (PlatformEvents_Distribution__mdt) binding.Data;

            if (!eventBusToConfigurationMap.containsKey(pedConfig.RelatedPlatformEventBus__c))
            {
                eventBusToConfigurationMap.put(pedConfig.RelatedPlatformEventBus__c, new List<PlatformEvents_Distribution__mdt>());
            }

            eventBusToConfigurationMap.get(pedConfig.RelatedPlatformEventBus__c).add(pedConfig);

            System.debug(eventBusToConfigurationMap);
        }
    }

    public static void triggerHandler()
    {
        if (Trigger.isExecuting && Trigger.isAfter && Trigger.isInsert)
        {
            triggerHandler(trigger.new);
        }
    }

    @TestVisible
    private static void triggerHandler(List<SObject> events)
    {

    }
}
