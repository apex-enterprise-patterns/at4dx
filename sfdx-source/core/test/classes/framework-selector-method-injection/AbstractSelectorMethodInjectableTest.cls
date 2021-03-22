/**
 * Copyright (c) 2020, John M. Daniel & John Storey
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
public with sharing class AbstractSelectorMethodInjectableTest {
    @IsTest
    static void verifyAbstractSelectorMethodInjection() {
        String keyName = 'fishy';

        List<Account> acctList = new List<Account> {
			new Account(Name=keyName),
			new Account(Name='TestAccount1') 
        };		
		insert acctList;

        Parameters queryParams = new Parameters();
        queryParams.nameSet = new Set<String>{ keyName };
        
        TestApplication_SObjectSelector testAppSOSelector =
            new TestApplication_SObjectSelector(); 

        test.startTest(); 
        List<Account> acctsReturned = 
            testAppSOSelector.selectInjection( 
                SelectByNameSelectorTestMethod.class, 
                queryParams  
        );
        test.stopTest();
        
        System.assertEquals(
            1,
            acctsReturned.size(),
            'Incorrect Amount of Records Returned'
        );

        Account acctToCheck = acctsReturned[0];
        System.assertEquals( 
            keyName,
            acctToCheck.Name,
            'Account Name Not Equal'
        );
    }

    private class SelectByNameSelectorMethod
    extends AbstractSelectorMethodInjectable
    implements ISelectorMethodInjectable
    {
        public List<SObject> selectQuery()
        {
            Parameters params = (Parameters)getParams(); 
            
            Set<String> nameSet = params.nameSet;
            
            return Database.query(newQueryFactory().setCondition(Account.Name+ ' in :nameSet').toSOQL());
        }
    }
        
    private class Parameters
        implements ISelectorMethodParameterable
    {
        public Set<String> nameSet;
    }

    private class TestApplication_SObjectSelector extends ApplicationSObjectSelector
	{
		public TestApplication_SObjectSelector()
		{
			super();
		}

        public List<Schema.SObjectField> getAdditionalSObjectFieldList()
            {
                return new List<Schema.SObjectField> {
                    Account.Name
                };
            }

		public Schema.SObjectType getSObjectType()
		{
			return Account.sObjectType;
		}
	}
}
