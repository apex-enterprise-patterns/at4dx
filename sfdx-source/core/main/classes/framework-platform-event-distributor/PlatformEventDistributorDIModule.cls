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
    @TestVisible
    private static List<PlatformEvents_Subscription__mdt> registeredSubscribers = new List<PlatformEvents_Subscription__mdt>();

    static
    {
        registeredSubscribers.addAll([select DeveloperName, Consumer__c, Event__c , EventCategory__c
                                         , MatcherRule__c, EventBus__c, Execute_Synchronous__c
                                      from PlatformEvents_Subscription__mdt 
                                     where IsActive__c = true]);
    }

    public override void configure()
    {
        String warningMessage = '';

        for ( PlatformEvents_Subscription__mdt registeredSubscriber : registeredSubscribers)
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
}
