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
 * - Neither the name of John M. Daniel, nor the names of its contributors 
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
@IsTest
private class PlatformEventDistributorDIModuleTest {
    @IsTest
    private static void whenPlatformEventSubscriptionEventBusBlankExceptionThrown()
    {
        PlatformEvents_Subscription__mdt platformEventSubscription = new PlatformEvents_Subscription__mdt(
            DeveloperName = 'PlatformEventDistributorBlankEventBus',
            Consumer__c = 'PlatformEventDistributorDIModuleTest.MockConsumer',
            IsActive__c = true,
            EventCategory__c = Account.getSObjectType().getDescribe().getName(),
            MatcherRule__c = 'MatchEventBusAndCategoryAndEventName',
            Event__c = 'PlatformEventDistributorBlankEventBus',
            Execute_Synchronous__c = true
        );

        // Inject platform event subscription into the DI module
        PlatformEventDistributorDIModule.registeredSubscribers.add(platformEventSubscription);

        try {
            new PlatformEventDistributorDIModule().configure();
        } catch (di_Module.ModuleException ex) {
            System.assertEquals(
                'Platform Events - Subscription record named, PlatformEventDistributorBlankEventBus, does not have required field, Event Bus', 
                ex.getMessage(), 
                'Event Bus exception does not match'
            );
        }
    }

    @IsTest
    private static void whenPlatformEventSubscriptionConsumerBlankExceptionThrown()
    {
        PlatformEvents_Subscription__mdt platformEventSubscription = new PlatformEvents_Subscription__mdt(
            DeveloperName = 'PlatformEventDistributorBlankEventBus',
            IsActive__c = true,
            EventCategory__c = Account.getSObjectType().getDescribe().getName(),
            MatcherRule__c = 'MatchEventBusAndCategoryAndEventName',
            EventBus__c = AT4DXMessage__e.getSObjectType().getDescribe().getName(),
            Event__c = 'PlatformEventDistributorBlankEventBus',
            Execute_Synchronous__c = true
        );

        // Inject platform event subscription into the DI module
        PlatformEventDistributorDIModule.registeredSubscribers.add(platformEventSubscription);

        try {
            new PlatformEventDistributorDIModule().configure();
        } catch (di_Module.ModuleException ex) {
            System.assertEquals(
                'Platform Events - Subscription record named, PlatformEventDistributorBlankEventBus, does not have required field, Consumer', 
                ex.getMessage(), 
                'Event Bus exception does not match'
            );
        }
    }

    @IsTest
    private static void whenPlatformEventSubscriptionCustomMetadataPresentVerifyForceDIBinding()
    {
        PlatformEvents_Subscription__mdt platformEventSubscription = new PlatformEvents_Subscription__mdt(
            DeveloperName = 'PlatformEventDistributor',
            Consumer__c = 'PlatformEventDistributorDIModuleTest.MockConsumer',
            IsActive__c = true,
            EventCategory__c = Account.getSObjectType().getDescribe().getName(),
            MatcherRule__c = 'MatchEventBusAndCategoryAndEventName',
            EventBus__c = AT4DXMessage__e.getSObjectType().getDescribe().getName(),
            Event__c = 'PlatformEventDistributor',
            Execute_Synchronous__c = true
        );

        Integer existingSubscriberCount = PlatformEventDistributorDIModule.registeredSubscribers.size();

        // Inject platform event subscription into the DI module
        PlatformEventDistributorDIModule.registeredSubscribers.add(platformEventSubscription);

        di_Module peModule = new PlatformEventDistributorDIModule();
        peModule.configure();

        System.assertEquals(existingSubscriberCount + 1, peModule.getBindings().size(), 'Incorrect number of bindings configured');
    }

    public class MockConsumer
        extends PlatformEventAbstractConsumer
    {
        public override void runInProcess()
        {
            System.debug('Mock Consumer');
        }
    }
}
