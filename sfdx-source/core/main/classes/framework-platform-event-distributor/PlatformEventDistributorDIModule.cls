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
    // Stores the list of registered subscribers
    @TestVisible
    private static List<PlatformEvents_Subscription__mdt> registeredSubscribers = new List<PlatformEvents_Subscription__mdt>();

    // Static initializer to populate the list of registerd subscribers when class is created
    // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_static.htm
    static
    {
        registeredSubscribers.addAll(
            [
                SELECT 
                    DeveloperName, 
                    Consumer__c, 
                    Event__c , 
                    EventCategory__c, 
                    MatcherRule__c, 
                    EventBus__c, 
                    Execute_Synchronous__c
                FROM PlatformEvents_Subscription__mdt 
                WHERE IsActive__c = TRUE
            ]
        );
    }

    public override void configure()
    {
        for (PlatformEvents_Subscription__mdt registeredSubscriber : registeredSubscribers)
        {
            fflib_SObjectDescribe eventBusDescribe = fflib_SObjectDescribe.getDescribe(registeredSubscriber.EventBus__c);

            // Validate record has EventBus field populated
            if (String.isBlank(registeredSubscriber.EventBus__c))
            {
                throw new ModuleException(SObjectType.PlatformEvents_Subscription__mdt.getLabel() + ' record named, ' 
                                            + registeredSubscriber.DeveloperName + ', does not have required field, ' 
                                            + PlatformEvents_Subscription__mdt.EventBus__c.getDescribe().getLabel());
            }

            // Validate record has Consumer field populated
            if (String.isBlank(registeredSubscriber.Consumer__c))
            {
                throw new ModuleException(SObjectType.PlatformEvents_Subscription__mdt.getLabel() + ' record named, ' 
                                            + registeredSubscriber.DeveloperName + ', does not have required field, ' 
                                            + PlatformEvents_Subscription__mdt.Consumer__c.getDescribe().getLabel());
            }

            apex();
            bind(eventBusDescribe.getSObjectType());
            bind(IEventsConsumer.class);
            data(registeredSubscriber);
            to(registeredSubscriber.Consumer__c);
        } 
    }
}
