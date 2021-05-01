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
public class PlatformEventDistributorTest
{
    @IsTest
    private static void whenTriggerHandlerInvokedWithEventsWithoutCategoryOrEventNameFieldExceptionThrown() 
    {
        try {
            new PlatformEventDistributor().triggerHandler(new List<Account>{new Account()});
        } catch (PlatformEventDistributor.PlatformEventDistributorException ex) {
            System.assertEquals('Platform Event must implement the Category and Event Name fields', ex.getMessage(), 'Unexpected exception message');
        }
    }

    @IsTest
    private static void whenTriggerHandlerInvokedWithMatchEventBusAndCategoryAndEventName() 
    {
        String eventName = 'TestMatchEventBusAndCategoryAndEventName';

        // Setup a platform event subscription
        PlatformEvents_Subscription__mdt platformEventSubscription = new PlatformEvents_Subscription__mdt(
            DeveloperName = 'TestMatchEventBusAndCategoryAndEventName',
            Consumer__c = 'PlatformEventDistributorTest.MatchEventBusAndCategoryAndEventNameConsumer',
            IsActive__c = true,
            EventCategory__c = Account.getSObjectType().getDescribe().getName(),
            MatcherRule__c = 'MatchEventBusAndCategoryAndEventName',
            EventBus__c = AT4DXMessage__e.SobjectType.getDescribe().getName(),
            Event__c = eventName,
            Execute_Synchronous__c = true
        );

        // Inject the subscription into the force-di cache
        di_Injector.Org.Bindings.add(
            new di_Module()
                .apex()
                .bind(AT4DXMessage__e.SObjectType)
                .bind(IEventsConsumer.class)
                .data(platformEventSubscription)
                .to(platformEventSubscription.Consumer__c)
        );

        // Setup a platform event to be published to the event bus
        AT4DXMessage__e platformEventMessage = new AT4DXMessage__e(
            EventName__c = eventName,
            Category__c = Account.getSObjectType().getDescribe().getName(),
            Payload__c = 'Test Payload'
        );

        // Inject the platform event directly into the trigger handler, bypassing event publishing
        new PlatformEventDistributor().triggerHandler(new List<AT4DXMessage__e> { platformEventMessage });

        System.assertEquals(true, matchEventBusAndCategoryAndEventNameResult.wasTestPlatformEventsConsumerCalled, 'Platform events consumer was not called');
        System.assertEquals('Test Payload', matchEventBusAndCategoryAndEventNameResult.testPlatformEventsConsumerData, 'Payload to consumer did not match');
    }

    @IsTest
    private static void whenTriggerHandlerInvokedWithMatchEventBusAndCategory() 
    {
        String eventName = 'TestMatchEventBusAndCategory';

        // Setup a platform event subscription
        PlatformEvents_Subscription__mdt platformEventSubscription = new PlatformEvents_Subscription__mdt(
            DeveloperName = 'TestMatchEventBusAndCategory',
            Consumer__c = 'PlatformEventDistributorTest.MatchEventBusAndCategoryConsumer',
            IsActive__c = true,
            EventCategory__c = Account.getSObjectType().getDescribe().getName(),
            MatcherRule__c = 'MatchEventBusAndCategory',
            EventBus__c = AT4DXMessage__e.SobjectType.getDescribe().getName(),
            Event__c = eventName,
            Execute_Synchronous__c = true
        );

        // Inject the subscription into the force-di cache
        di_Injector.Org.Bindings.add(
            new di_Module()
                .apex()
                .bind(AT4DXMessage__e.SObjectType)
                .bind(IEventsConsumer.class)
                .data(platformEventSubscription)
                .to(platformEventSubscription.Consumer__c)
        );

        // Setup a platform event to be published to the event bus
        AT4DXMessage__e platformEventMessage = new AT4DXMessage__e(
            EventName__c = eventName,
            Category__c = Account.getSObjectType().getDescribe().getName(),
            Payload__c = 'Test Payload'
        );

        // Inject the platform event directly into the trigger handler, bypassing event publishing
        new PlatformEventDistributor().triggerHandler(new List<AT4DXMessage__e> { platformEventMessage });

        System.assertEquals(true, matchEventBusAndCategoryResult.wasTestPlatformEventsConsumerCalled, 'Platform events consumer was not called');
        System.assertEquals('Test Payload', matchEventBusAndCategoryResult.testPlatformEventsConsumerData, 'Payload to consumer did not match');        
    }

    @IsTest
    private static void whenTriggerHandlerInvokedWithMatchEventBusAndEventName() 
    {
        String eventName = 'TestMatchEventBusAndEventName';

        // Setup a platform event subscription
        PlatformEvents_Subscription__mdt platformEventSubscription = new PlatformEvents_Subscription__mdt(
            DeveloperName = 'TestMatchEventBusAndEventName',
            Consumer__c = 'PlatformEventDistributorTest.MatchEventBusAndEventNameConsumer',
            IsActive__c = true,
            EventCategory__c = Account.getSObjectType().getDescribe().getName(),
            MatcherRule__c = 'MatchEventBusAndEventName',
            EventBus__c = AT4DXMessage__e.SobjectType.getDescribe().getName(),
            Event__c = eventName,
            Execute_Synchronous__c = true
        );

        // Inject the subscription into the force-di cache
        di_Injector.Org.Bindings.add(
            new di_Module()
                .apex()
                .bind(AT4DXMessage__e.SObjectType)
                .bind(IEventsConsumer.class)
                .data(platformEventSubscription)
                .to(platformEventSubscription.Consumer__c)
        );

        // Setup a platform event to be published to the event bus
        AT4DXMessage__e platformEventMessage = new AT4DXMessage__e(
            EventName__c = eventName,
            Category__c = Account.getSObjectType().getDescribe().getName(),
            Payload__c = 'Test Payload'
        );

        // Inject the platform event directly into the trigger handler, bypassing event publishing
        new PlatformEventDistributor().triggerHandler(new List<AT4DXMessage__e> { platformEventMessage });

        System.assertEquals(true, matchEventBusAndEventNameResult.wasTestPlatformEventsConsumerCalled, 'Platform events consumer was not called');
        System.assertEquals('Test Payload', matchEventBusAndEventNameResult.testPlatformEventsConsumerData, 'Payload to consumer did not match');    
    }

    @IsTest
    private static void whenTriggerHandlerInvokedWithMatchEventBus() 
    {
        String eventName = 'TestMatchEventBus';

        // Setup a platform event subscription
        PlatformEvents_Subscription__mdt platformEventSubscription = new PlatformEvents_Subscription__mdt(
            DeveloperName = 'TestMatchEventBus',
            Consumer__c = 'PlatformEventDistributorTest.MatchEventBusConsumer',
            IsActive__c = true,
            EventCategory__c = Account.getSObjectType().getDescribe().getName(),
            MatcherRule__c = 'MatchEventBus',
            EventBus__c = AT4DXMessage__e.SobjectType.getDescribe().getName(),
            Event__c = eventName,
            Execute_Synchronous__c = true
        );

        // Inject the subscription into the force-di cache
        di_Injector.Org.Bindings.add(
            new di_Module()
                .apex()
                .bind(AT4DXMessage__e.SObjectType)
                .bind(IEventsConsumer.class)
                .data(platformEventSubscription)
                .to(platformEventSubscription.Consumer__c)
        );

        // Setup a platform event to be published to the event bus
        AT4DXMessage__e platformEventMessage = new AT4DXMessage__e(
            EventName__c = eventName,
            Category__c = Account.getSObjectType().getDescribe().getName(),
            Payload__c = 'Test Payload'
        );

        // Inject the platform event directly into the trigger handler, bypassing event publishing
        new PlatformEventDistributor().triggerHandler(new List<AT4DXMessage__e> { platformEventMessage });

        System.assertEquals(true, matchEventBusResult.wasTestPlatformEventsConsumerCalled, 'Platform events consumer was not called');
        System.assertEquals('Test Payload', matchEventBusResult.testPlatformEventsConsumerData, 'Payload to consumer did not match');    
    }

    @IsTest
    private static void whenTriggerHandlerInvokedWithMatchEventBusWithAsynchronousSubscriber() 
    {
        String eventName = 'TestMatchEventBusAsynchronous';

        // Setup a platform event subscription
        PlatformEvents_Subscription__mdt platformEventSubscription = new PlatformEvents_Subscription__mdt(
            DeveloperName = 'TestMatchEventBusAsynchronous',
            Consumer__c = 'PlatformEventDistributorTest.MatchEventBusConsumerAsynchronous',
            IsActive__c = true,
            EventCategory__c = Account.getSObjectType().getDescribe().getName(),
            MatcherRule__c = 'MatchEventBus',
            EventBus__c = AT4DXMessage__e.SobjectType.getDescribe().getName(),
            Event__c = eventName,
            Execute_Synchronous__c = false
        );

        // Inject the subscription into the force-di cache
        di_Injector.Org.Bindings.add(
            new di_Module()
                .apex()
                .bind(AT4DXMessage__e.SObjectType)
                .bind(IEventsConsumer.class)
                .data(platformEventSubscription)
                .to(platformEventSubscription.Consumer__c)
        );

        // Setup a platform event to be published to the event bus
        AT4DXMessage__e platformEventMessage = new AT4DXMessage__e(
            EventName__c = eventName,
            Category__c = Account.getSObjectType().getDescribe().getName(),
            Payload__c = 'Test Payload'
        );

        // Inject the platform event directly into the trigger handler, bypassing event publishing
        PlatformEventDistributor pedInstance = new PlatformEventDistributor();
        pedInstance.triggerHandler(new List<AT4DXMessage__e> { platformEventMessage });

        System.assertEquals(false, pedInstance.jobIdList.isEmpty(), 'Job id was not found in the job id list');  
    }

    @IsTest
    private static void whenInvalidConsumerSuppliedExceptionThrown() 
    {
        String eventName = 'TestMatchEventBusInvalidConsumer';

        // Setup a platform event subscription
        PlatformEvents_Subscription__mdt platformEventSubscription = new PlatformEvents_Subscription__mdt(
            DeveloperName = 'TestMatchEventBusInvalidConsumer',
            Consumer__c = 'PlatformEventDistributorTest.InvalidConsumer',
            IsActive__c = true,
            EventCategory__c = Account.getSObjectType().getDescribe().getName(),
            MatcherRule__c = 'MatchEventBus',
            EventBus__c = AT4DXMessage__e.SobjectType.getDescribe().getName(),
            Event__c = eventName,
            Execute_Synchronous__c = true
        );

        // Inject the subscription into the force-di cache
        di_Injector.Org.Bindings.add(
            new di_Module()
                .apex()
                .bind(AT4DXMessage__e.SObjectType)
                .bind(IEventsConsumer.class)
                .data(platformEventSubscription)
                .to(platformEventSubscription.Consumer__c)
        );

        // Setup a platform event to be published to the event bus
        AT4DXMessage__e platformEventMessage = new AT4DXMessage__e(
            EventName__c = eventName,
            Category__c = Account.getSObjectType().getDescribe().getName(),
            Payload__c = 'Test Payload'
        );

        try {
            new PlatformEventDistributor().triggerHandler(new List<AT4DXMessage__e> { platformEventMessage });
        } catch (Exception ex) {
            System.assertEquals('Attempt to de-reference a null object', ex.getMessage(), 'Null pointer exception was not thrown');
        }
    }

    @IsTest
    private static void whenAT4DXMessagePublishedToEventBusTriggerHandlerProcessesEvent() {
        AT4DXMessage__e platformEventMessage = new AT4DXMessage__e(
            EventName__c = 'TestTrigger',
            Category__c = Account.getSObjectType().getDescribe().getName(),
            Payload__c = 'Test Payload'
        );

        Test.startTest();
        Database.SaveResult sr = EventBus.publish(platformEventMessage);
        Integer initialSubscriberPosition = getCurrentEventBusSubscriberPosition(AT4DXMessage__e.SobjectType);
        Test.stopTest();

        System.assertEquals(true, sr.isSuccess(), 'Platform event was not successfully published to the bus');
        System.assert(initialSubscriberPosition < getCurrentEventBusSubscriberPosition(AT4DXMessage__e.SobjectType), 'The current event bus subscriber position did not change.  This indicates that the Apex Platform event subscriber trigger did not activate.');
    }

    @IsTest
    private static void whenAT4DXImmediateMessagePublishedToEventBusTriggerHandlerProcessesEvent() {
        AT4DXImmediateMessage__e platformEventMessage = new AT4DXImmediateMessage__e(
            EventName__c = 'TestTrigger',
            Category__c = Account.getSObjectType().getDescribe().getName(),
            Payload__c = 'Test Payload'
        );

        Test.startTest();
        Database.SaveResult sr = EventBus.publish(platformEventMessage);
        Integer initialSubscriberPosition = getCurrentEventBusSubscriberPosition(AT4DXImmediateMessage__e.SobjectType);
        Test.stopTest();

        System.assertEquals(true, sr.isSuccess(), 'Platform event was not successfully published to the bus');
        System.assert(initialSubscriberPosition < getCurrentEventBusSubscriberPosition(AT4DXImmediateMessage__e.SobjectType), 'The current event bus subscriber position did not change.  This indicates that the Apex Platform event subscriber trigger did not activate.');
    }

    private class PlatformEventConsumerResult {
        public Boolean wasTestPlatformEventsConsumerCalled = false;
        public String testPlatformEventsConsumerData = null;
    }

    private static PlatformEventConsumerResult matchEventBusAndCategoryAndEventNameResult = new PlatformEventConsumerResult();
    private static PlatformEventConsumerResult matchEventBusAndCategoryResult = new PlatformEventConsumerResult();
    private static PlatformEventConsumerResult matchEventBusAndEventNameResult = new PlatformEventConsumerResult();
    private static PlatformEventConsumerResult matchEventBusResult = new PlatformEventConsumerResult();

    public class MatchEventBusAndCategoryAndEventNameConsumer
        extends PlatformEventAbstractConsumer
    {
        public override void runInProcess()
        {
            matchEventBusAndCategoryAndEventNameResult.wasTestPlatformEventsConsumerCalled = true;

            for (SObject sobj : events) 
            {
                AT4DXMessage__e eventPayload = (AT4DXMessage__e) sobj;
                matchEventBusAndCategoryAndEventNameResult.testPlatformEventsConsumerData = ((AT4DXMessage__e) sobj).Payload__c;
            }
        }
    }

    public class MatchEventBusAndCategoryConsumer
        extends PlatformEventAbstractConsumer
    {
        public override void runInProcess()
        {
            matchEventBusAndCategoryResult.wasTestPlatformEventsConsumerCalled = true;

            for (SObject sobj : events) 
            {
                AT4DXMessage__e eventPayload = (AT4DXMessage__e) sobj;
                matchEventBusAndCategoryResult.testPlatformEventsConsumerData = ((AT4DXMessage__e) sobj).Payload__c;
            }
        }
    }

    public class MatchEventBusAndEventNameConsumer
        extends PlatformEventAbstractConsumer
    {
        public override void runInProcess()
        {
            matchEventBusAndEventNameResult.wasTestPlatformEventsConsumerCalled = true;

            for (SObject sobj : events) 
            {
                AT4DXMessage__e eventPayload = (AT4DXMessage__e) sobj;
                matchEventBusAndEventNameResult.testPlatformEventsConsumerData = ((AT4DXMessage__e) sobj).Payload__c;
            }
        }
    }

    public class MatchEventBusConsumer
        extends PlatformEventAbstractConsumer
    {
        public override void runInProcess()
        {
            matchEventBusResult.wasTestPlatformEventsConsumerCalled = true;

            for (SObject sobj : events) 
            {
                AT4DXMessage__e eventPayload = (AT4DXMessage__e) sobj;
                matchEventBusResult.testPlatformEventsConsumerData = ((AT4DXMessage__e) sobj).Payload__c;
            }
        }
    }

    public class MatchEventBusConsumerAsynchronous
        extends PlatformEventAbstractConsumer
    {
        public override void runInProcess()
        {
            matchEventBusResult.wasTestPlatformEventsConsumerCalled = true;

            for (SObject sobj : events) 
            {
                AT4DXMessage__e eventPayload = (AT4DXMessage__e) sobj;
                matchEventBusResult.testPlatformEventsConsumerData = ((AT4DXMessage__e) sobj).Payload__c;
            }
        }
    }

    private static Integer getCurrentEventBusSubscriberPosition(SobjectType sobjtype)
    {
        EventBusSubscriber messageBusSubscriber = [SELECT Id, ExternalId, Name, Type, Topic, Position, Tip, Retries, LastError, Status 
                                                          FROM EventBusSubscriber 
                                                         WHERE Topic = :sobjtype.getDescribe().getName()
                                                           AND Type = 'ApexTrigger'
                                                         LIMIT 1];
        
        System.assert(messageBusSubscriber != null, 'Could not find the ' + sobjtype + ' record');

        return messageBusSubscriber.Position;
    }
}
