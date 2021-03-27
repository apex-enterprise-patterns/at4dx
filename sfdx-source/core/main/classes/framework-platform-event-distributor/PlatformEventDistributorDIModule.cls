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

public class PlatformEventDistributorDIModule
    extends di_Module
{
    // public override void configure()
    // {
    //     Schema.DescribeSobjectResult[] results = null;

    //     for (ConfigWrapper bindingConfigWrapper : getConfigurationList())
    //     {
    //         // Validate the subscription record first.

    //         if (String.isBlank(bindingConfigWrapper.EventBus))
    //         {
    //             System.debug(
    //                 LoggingLevel.WARN, 
    //                 SObjectType.PlatformEvents_Subscription__mdt.getLabel() + ' record named, ' + bindingConfigWrapper.DeveloperName +
    //                 ', does not have required field, ' + PlatformEvents_Subscription__mdt.EventBus__c.getDescribe().getLabel());
    //             continue;
    //         }

    //         if (String.isBlank(bindingConfigWrapper.Consumer))
    //         {
    //             System.debug(
    //                 LoggingLevel.WARN, 
    //                 SObjectType.PlatformEvents_Subscription__mdt.getLabel() + ' record named, ' + bindingConfigWrapper.DeveloperName +
    //                 ', does not have required field, ' + PlatformEvents_Subscription__mdt.Consumer__c.getDescribe().getLabel());
    //             continue;
    //         }

    //         apex();
    //         bind(bindingConfigWrapper.EventBus);
    //         bind(IEventsConsumer.class);
    //         data(bindingConfigWrapper.record);
    //         to(bindingConfigWrapper.Consumer);
    //     }
    // }

    public override void configure()
    {
        String warningMessage = '';

        for ( PlatformEvents_Subscription__mdt registeredSubscriber : getRegisteredSubscribers())
        {
            warningMessage = '';
            
            // Validate the subscription record first.
            if (String.isBlank(registeredSubscriber.EventBus__c))
            {
                warningMessage += SObjectType.PlatformEvents_Subscription__mdt.getLabel() + ' record named, ' 
                                    + registeredSubscriber.DeveloperName + ', does not have required field, ' 
                                    + PlatformEvents_Subscription__mdt.EventBus__c.getDescribe().getLabel();

            }

            if (String.isBlank(registeredSubscriber.Consumer__c))
            {
                warningMessage += (String.isNotBlank(warningMessage) ? '\n' : '')
                                    + SObjectType.PlatformEvents_Subscription__mdt.getLabel() + ' record named, ' 
                                    + registeredSubscriber.DeveloperName + ', does not have required field, ' 
                                    + PlatformEvents_Subscription__mdt.Consumer__c.getDescribe().getLabel();
            }

            if (String.isNotBlank(warningMessage))
            {
                System.debug( LoggingLevel.WARN, warningMessage );
                continue;
            }

            apex();
            bind(registeredSubscriber.EventBus__c);
            bind(IEventsConsumer.class);
            data(registeredSubscriber);
            to(registeredSubscriber.Consumer__c);       
        } 
    }

    @TestVisible
    private static List<PlatformEvents_Subscription__mdt> registeredSubscribers = new List<PlatformEvents_Subscription__mdt>();

    private List<PlatformEvents_Subscription__mdt> getRegisteredSubscribers()
    {
        registeredSubscribers.addAll([select DeveloperName, Consumer__c, Event__c , EventCategory__c
                                         , MatcherRule__c, EventBus__c, Execute_Synchronous__c
                                      from PlatformEvents_Subscription__mdt 
                                     where IsActive__c = true]);

        return registeredSubscribers;
    }

    // @TestVisible
    // private List<ConfigWrapper> getConfigurationList()
    // {
        // List<ConfigWrapper> result = new List<ConfigWrapper>();

        // for ( PlatformEvents_Subscription__mdt bindingConfig : [select DeveloperName, Consumer__c, Event__c , EventCategory__c, MatcherRule__c, EventBus__c, Execute_Synchronous__c
        //         from PlatformEvents_Subscription__mdt where IsActive__c = true])
        // {
        //     result.add(new ConfigWrapper(bindingConfig));
        // }

//        if (mock_BindingConfigurationWrappers != null) result = mock_BindingConfigurationWrappers;

        // return result;
    // }

    // @TestVisible
    // private class ConfigWrapper
    // {
    //     public String DeveloperName = null;
    //     public String Consumer = null;
    //     public String Event = null;
    //     public String EventCategory = null;
    //     public String MatcherRule = null;
    //     public String EventBus = null;
    //     public Boolean ExecuteSynchronous = null;
    //     public PlatformEvents_Subscription__mdt record = null;

    //     public ConfigWrapper(PlatformEvents_Subscription__mdt bindingConfig)
    //     {
    //         this.DeveloperName = bindingConfig.DeveloperName;
    //         this.Consumer = bindingConfig.Consumer__c;
    //         this.Event = bindingConfig.Event__c;
    //         this.EventCategory = bindingConfig.EventCategory__c;
    //         this.MatcherRule = bindingConfig.MatcherRule__c;
    //         this.EventBus = bindingConfig.EventBus__c;
    //         this.ExecuteSynchronous = bindingConfig.Execute_Synchronous__c;
    //         this.record = bindingConfig;
    //     }

    //     @TestVisible
    //     private ConfigWrapper(
    //         String DeveloperName,
    //         String Consumer,
    //         String Event,
    //         String EventCategory,
    //         String MatcherRule,
    //         String EventBus,
    //         Boolean ExecuteSynchronous
    //     )
    //     {
    //         this.DeveloperName = DeveloperName;
    //         this.Consumer = Consumer;
    //         this.Event = Event;
    //         this.EventCategory = EventCategory;
    //         this.MatcherRule = MatcherRule;
    //         this.EventBus = EventBus;
    //         this.ExecuteSynchronous = ExecuteSynchronous;

    //         this.record = new PlatformEvents_Subscription__mdt();
    //         this.record.DeveloperName = DeveloperName;
    //         this.record.Consumer__c = Consumer;
    //         this.record.Event__c = Event;
    //         this.record.EventCategory__c = EventCategory;
    //         this.record.MatcherRule__c = MatcherRule;
    //         this.record.EventBus__c = EventBus;
    //         this.record.Execute_Synchronous__c = ExecuteSynchronous;
    //     }
    // }

    // private static List<ConfigWrapper> mock_BindingConfigurationWrappers = null;
}
