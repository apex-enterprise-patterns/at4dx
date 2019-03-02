/**
 * Copyright (c) 2018, John M. Daniel
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

@IsTest
public class PlatformEventDistributorTest
{
    @IsTest
    static void EventAndCategoryTest()
    {
        Event__e platformEventbus = new Event__e();

        platformEventbus.EventName__c = 'Account_Slogan_Has_Changed';
        platformEventbus.Category__c = Account.getSObjectType().getDescribe().getName();
        platformEventbus.Payload__c = json.serialize(new Set<Id>{ fflib_IDGenerator.generate(Account.SObjectType)});

        PlatformEventDistributor ped = new PlatformEventDistributor();

        Test.startTest();
        ped.triggerHandler(new List<Event__e> {platformEventbus});
        Test.stopTest();

        System.assertNotEquals(null, ped.jobIdList);
        System.assertEquals(1, ped.jobIdList.size());
    }

    @isTest
    private static void basicTestToActivateCodeCoverage() 
    {
        Event__e platformEventbus = new Event__e();

        platformEventbus.EventName__c = 'bluefish';
        platformEventbus.Category__c = Account.getSObjectType().getDescribe().getName();
        platformEventbus.Payload__c = json.serialize( new Set<Id>{ fflib_IDGenerator.generate(Account.SObjectType ) } );

        Test.startTest();
        Database.SaveResult sr = EventBus.publish(platformEventbus);
        Test.stopTest();

        System.assertEquals(true, sr.isSuccess());
    }
}
