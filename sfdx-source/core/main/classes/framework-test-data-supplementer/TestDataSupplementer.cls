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
public class TestDataSupplementer
{
    private static Map<SObjectType, List<ITestDataSupplement>> supplementerMap = new Map<SObjectType, List<ITestDataSupplement>>();

    static
    {
        for (
            di_Binding binding
            :
            di_Injector.Org.Bindings
                .byName(ITestDataSupplement.class.getName())
                .get()
        )
        {
            TestDataSupplementer__mdt tds_mdt = (TestDataSupplementer__mdt) binding.Data;

            SObjectType sobjType = Schema.getGlobalDescribe().get( String.isNotBlank(tds_mdt.BindingSObject__c) ? tds_mdt.BindingSObject__c : tds_mdt.BindingSObjectAlternate__c );

            if (!supplementerMap.containsKey(sobjType))
            {
                supplementerMap.put(sobjType, new List<ITestDataSupplement>());
            }

            supplementerMap.get(sobjType).add((ITestDataSupplement) binding.getInstance());
        }
    }

    public static void supplement(List<SObject> sobjectList)
    {
        if (sobjectList != null && !sobjectList.isEmpty())
        {
            for (ITestDataSupplement supplementer : supplementerMap.get(sobjectList.getSObjectType()))
            {
                supplementer.supplement(sobjectList);
            }
        }
    }
}
