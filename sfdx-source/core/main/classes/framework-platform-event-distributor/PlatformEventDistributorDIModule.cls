public class PlatformEventDistributorDIModule
    extends di_Module
{
    public override void configure()
    {
        Schema.DescribeSobjectResult[] results = null;

        for (ConfigWrapper bindingConfigWrapper : getConfigurationList())
        {
            // Validate the distribution record first.

            if (String.isBlank(bindingConfigWrapper.EventBus))
            {
                System.debug(
                    LoggingLevel.WARN, 
                    SObjectType.PlatformEvents_Distribution__mdt.getLabel() + ' record named, ' + bindingConfigWrapper.DeveloperName +
                    ', does not have required field, ' + PlatformEvents_Distribution__mdt.EventBus__c.getDescribe().getLabel());
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

            apex();
            bind(bindingConfigWrapper.EventBus);
            bind(IEventsConsumer.class);
            data(bindingConfigWrapper.record);
            to(bindingConfigWrapper.Consumer);
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
                DeveloperName, Consumer__c, Event__c , EventCategory__c, MatcherRule__c, EventBus__c 
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
        public String EventCategory = null;
        public String MatcherRule = null;
        public String EventBus = null;
        public PlatformEvents_Distribution__mdt record = null;

        public ConfigWrapper(PlatformEvents_Distribution__mdt bindingConfig)
        {
            this.DeveloperName = bindingConfig.DeveloperName;
            this.Consumer = bindingConfig.Consumer__c;
            this.Event = bindingConfig.Event__c;
            this.EventCategory = bindingConfig.EventCategory__c;
            this.MatcherRule = bindingConfig.MatcherRule__c;
            this.EventBus = bindingConfig.EventBus__c;
            this.record = bindingConfig;
        }

        @TestVisible
        private ConfigWrapper(
            String DeveloperName,
            String Consumer,
            String Event,
            String EventCategory,
            String MatcherRule,
            String EventBus
        )
        {
            this.DeveloperName = DeveloperName;
            this.Consumer = Consumer;
            this.Event = Event;
            this.EventCategory = EventCategory;
            this.MatcherRule = MatcherRule;
            this.EventBus = EventBus;
            this.record = new PlatformEvents_Distribution__mdt();
        }
    }

    @TestVisible
    List<ConfigWrapper> mock_BindingConfigurationWrappers = null;
}
