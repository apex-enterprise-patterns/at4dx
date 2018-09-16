public class PlatformEventDistributorDIModule
    extends di_Module
{
    public override void configure()
    {
        Schema.DescribeSobjectResult[] results = null;

        for (ConfigWrapper bindingConfigWrapper : getConfigurationList())
        {
            // Validate the distribution record first.

            if (String.isBlank(bindingConfigWrapper.RelatedPlatformEventBus))
            {
                System.debug(
                    LoggingLevel.WARN, 
                    SObjectType.PlatformEvents_Distribution__mdt.getLabel() + ' record named, ' + bindingConfigWrapper.DeveloperName +
                    ', does not have required field, ' + PlatformEvents_Distribution__mdt.RelatedPlatformEventBus__c.getDescribe().getLabel());
                continue;
            }

            if (String.isBlank(bindingConfigWrapper.Consumer))
            {
                System.debug(
                    LoggingLevel.WARN, 
                    SObjectType.PlatformEvents_Distribution__mdt.getLabel() + ' record named, ' + bindingConfigWrapper.DeveloperName +
                    ', does not have required field, ' + PlatformEvents_Distribution__mdt.Consumer__c.getDescribe().getLabel());
                continue;
            }

            apex().bind(bindingConfigWrapper.RelatedPlatformEventBus).bind(IEventsConsumer.class)
                .data(bindingConfigWrapper.record)
                .to(bindingConfigWrapper.Consumer);
        }
    }

    @TestVisible
    private List<ConfigWrapper> getConfigurationList()
    {
        List<ConfigWrapper> result = new List<ConfigWrapper>();

        for (
            PlatformEvents_Distribution__mdt bindingConfig
            :
            [select 
                DeveloperName, Consumer__c, Event__c, EventSObjectCategory__c, MatcherRule__c, RelatedPlatformEventBus__c
                from PlatformEvents_Distribution__mdt where IsActive__c = true]
        )
        {
            result.add(new ConfigWrapper(bindingConfig));
        }

        if (mock_BindingConfigurationWrappers != null) result = mock_BindingConfigurationWrappers;

        return result;
    }

    @TestVisible
    private class ConfigWrapper
    {
        public String DeveloperName = null;
        public String Consumer = null;
        public String Event = null;
        public String EventSObjectCategory = null;
        public String MatcherRule = null;
        public String RelatedPlatformEventBus = null;
        public PlatformEvents_Distribution__mdt record = null;

        public ConfigWrapper(PlatformEvents_Distribution__mdt bindingConfig)
        {
            this.DeveloperName = bindingConfig.DeveloperName;
            this.Consumer = bindingConfig.Consumer__c;
            this.Event = bindingConfig.Event__c;
            this.EventSObjectCategory = bindingConfig.EventSObjectCategory__c;
            this.MatcherRule = bindingConfig.MatcherRule__c;
            this.RelatedPlatformEventBus = bindingConfig.RelatedPlatformEventBus__c;
            this.record = bindingConfig;
        }

        @TestVisible
        private ConfigWrapper(
            String DeveloperName,
            String Consumer,
            String Event,
            String EventSObjectCategory,
            String MatcherRule,
            String RelatedPlatformEventBus
        )
        {
            this.DeveloperName = DeveloperName;
            this.Consumer = Consumer;
            this.Event = Event;
            this.EventSObjectCategory = EventSObjectCategory;
            this.MatcherRule = MatcherRule;
            this.RelatedPlatformEventBus = RelatedPlatformEventBus;
            this.record = new PlatformEvents_Distribution__mdt();
        }
    }

    @TestVisible
    List<ConfigWrapper> mock_BindingConfigurationWrappers = null;
}
