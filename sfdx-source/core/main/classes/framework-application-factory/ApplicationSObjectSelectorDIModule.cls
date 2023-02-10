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

/**
 *
 * di_Module based class used to manage the Application Factory mappings of for the SOBject
 */
public class ApplicationSObjectSelectorDIModule 
    extends di_Module
{
    @TestVisible
    private static List<ApplicationFactory_SelectorBinding__mdt> bindingRecords = new List<ApplicationFactory_SelectorBinding__mdt>();

    static
    {
        bindingRecords = prioritizeBindings(
            [SELECT DeveloperName, QualifiedAPIName, To__c, BindingSObject__c, BindingSObject__r.QualifiedApiName, BindingSObjectAlternate__c
            FROM ApplicationFactory_SelectorBinding__mdt ORDER BY Priority__c DESC NULLS FIRST]
            // Lower priority records are added first and overwritten if higher priority items exist.
            // If priority value is duplicated, the priority item is indeterminant.
        );
    }

    public override void configure() 
    {
        Schema.DescribeSobjectResult[] results = null;

        String bindingSObjectAPIName = null;

        for ( ApplicationFactory_SelectorBinding__mdt bindingConfig : bindingRecords )
        {
            bindingSObjectAPIName = String.isNotBlank(bindingConfig.BindingSObject__c) ? bindingConfig.BindingSObject__r.QualifiedApiName : bindingConfig.BindingSObjectAlternate__c;

            apex();
            if (String.isNotBlank(bindingSObjectAPIName)) 
            {
                results = Schema.describeSObjects(new String[] { bindingSObjectAPIName.toLowerCase().trim() });
                if(results.size() != 1) 
                {
                    throw new di_Injector.InjectorException('Failed to find SObject ' + bindingSObjectAPIName
                                                              + ' referened by binding ' + bindingConfig.DeveloperName 
                                                              + ' for ApplicationSObjectSelectorDIModule di_Injectory module.');
                }
                bind(results[0].getSObjectType());
                bind(IApplicationSObjectSelector.class);
            }
            data(bindingConfig);
            to(bindingConfig.To__c);
        }
    }

    private static List<ApplicationFactory_SelectorBinding__mdt> prioritizeBindings(List<ApplicationFactory_SelectorBinding__mdt> rawBindings)
    {
        Map<String, ApplicationFactory_SelectorBinding__mdt> prioritizedMap = new Map<String, ApplicationFactory_SelectorBinding__mdt>();
        for (ApplicationFactory_SelectorBinding__mdt binding : rawBindings)
        {
            String sobjTypeName = String.isNotBlank(binding.BindingSObject__c) ? binding.BindingSObject__r.QualifiedApiName : binding.BindingSObjectAlternate__c;
            prioritizedMap.put(sobjTypeName, binding);
        }
        return prioritizedMap.values();
    }
}
