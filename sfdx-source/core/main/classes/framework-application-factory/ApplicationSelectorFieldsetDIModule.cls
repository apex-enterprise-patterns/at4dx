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

public class ApplicationSelectorFieldsetDIModule
    extends di_Module
{
    private static Map<SObjectType, Set<String>> FIELDSETNAMES_BY_SOBJECTTYPE_MAP;

    static 
    {
        FIELDSETNAMES_BY_SOBJECTTYPE_MAP = new Map<SObjectType, Set<String>>();

        Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe();

        SObjectType soType = null;

        String bindingSObjectAPIName = null;

        list<SelectorConfig_FieldSetInclusion__mdt> bindingRecords = [select Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName
                                                                               , BindingSObject__c, BindingSObject__r.QualifiedApiName, BindingSObjectAlternate__c, FieldsetName__c
                                                                            from SelectorConfig_FieldSetInclusion__mdt
                                                                           where IsActive__c = true];

        for (SelectorConfig_FieldSetInclusion__mdt scfi : bindingRecords )
        {
            bindingSObjectAPIName = String.isNotBlank(scfi.BindingSObject__c) ? scfi.BindingSObject__r.QualifiedApiName : scfi.BindingSObjectAlternate__c; 

            soType = globalDescribeMap.get( bindingSObjectAPIName.toLowerCase());

            if ( soType != null )
            {
                if ( ! FIELDSETNAMES_BY_SOBJECTTYPE_MAP.containsKey(soType) )
                {
                    FIELDSETNAMES_BY_SOBJECTTYPE_MAP.put(soType, new Set<String>());
                }

                // if the fieldset name does exist
                if( soType.getDescribe().fieldSets.getMap().containsKey( scfi.FieldsetName__c.toLowerCase() ) )
                {
                    // ... then add the fieldset to the map
                    FIELDSETNAMES_BY_SOBJECTTYPE_MAP.get(soType).add( scfi.FieldsetName__c.toLowerCase() );
                }
            }
        }
    }

    public override void configure() 
    {
        // loop through the FIELDSETNAMES_BY_SOBJECTTYPE_MAP // Map<SObjectType, Set<String>>
        for (SObjectType sobjTypeKey : FIELDSETNAMES_BY_SOBJECTTYPE_MAP.keySet())
        {
            for ( String fieldSetName : FIELDSETNAMES_BY_SOBJECTTYPE_MAP.get( sobjTypeKey ) )
            {
                apex().bind( sobjTypeKey ).bind( Schema.Fieldset.class )
                    .to( fieldSetName );
            }
        }
    }
}
