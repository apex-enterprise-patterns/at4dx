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

/**
 * Applicaiton specific Domain base class, customise fflib_SObjectSelector and add common behavior
 **/
public abstract class ApplicationSObjectSelector extends fflib_SObjectSelector {

    private static Map<SObjectType, Set<String>> standardSObjectFieldsNotToIncludeSetBySObjectTYpeMap = new Map<SObjectType, Set<String>>();

    static
    {
        // Put the fields in as strings and not SObjectFields because sometimes you want to exclude
        //  a field that is only present in certain orgs.  Account.OperatinHoursId and Account.NameLocal
        //  are two such fields.
        standardSObjectFieldsNotToIncludeSetBySObjectTYpeMap.put( User.SObjectType, new Set<string>() );
        standardSObjectFieldsNotToIncludeSetBySObjectTYpeMap.get( User.SObjectType).add( 'SmallBannerPhotoUrl'.toLowerCase() );
        standardSObjectFieldsNotToIncludeSetBySObjectTYpeMap.get( User.SObjectType).add( 'MediumBannerPhotoUrl'.toLowerCase() );

        standardSObjectFieldsNotToIncludeSetBySObjectTYpeMap.put( Account.SObjectType, new Set<string>() );
        standardSObjectFieldsNotToIncludeSetBySObjectTYpeMap.get( Account.SObjectType).add( 'OperatingHoursId'.toLowerCase() );
        standardSObjectFieldsNotToIncludeSetBySObjectTYpeMap.get( Account.SObjectType).add('NameLocal'.toLowerCase() );
    }

    protected List<Schema.FieldSet> sObjectFieldSetList = new List<Schema.FieldSet>();

    private void incorporateAdditionalSObjectFields()
    {
        List<Fieldset> results = new List<Fieldset>();

        Map<String, Schema.FieldSet> fieldSetMap = getSObjectType().getDescribe().fieldSets.getMap();

        list<di_Binding> bindings = di_Injector.Org.Bindings.byName(Schema.FieldSet.class.getName())
                                                    .bySObject(getSObjectType())
                                                    .get();

        for ( di_Binding binding : bindings )
        {
            results.add(fieldsetMap.get(((String)binding.To).toLowerCase()));
        }
        this.sObjectFieldSetList.addAll(results);
    }

    public ApplicationSObjectSelector() {
        // first parameter -- includeFieldSetFields -- must be true for the selector field injection to work
        // Disable the base class read security checking in preference to explicit checking elsewhere
        this(true, false, false);
    }
    
    public ApplicationSObjectSelector(Boolean includeFieldSetFields, Boolean enforceCRUD, Boolean enforceFLS) {
        // Disable sorting of selected fields to aid debugging (performance optimisation)
        super(includeFieldSetFields, enforceCRUD, enforceFLS, false);
        incorporateAdditionalSObjectFields();
    }

    public override virtual List<Schema.FieldSet> getSObjectFieldSetList()
    {
        return this.sObjectFieldSetList;
    }

    /**
     * Implement this method to inform the base class of the SObject (custom or standard) to be queried
     **/
    abstract Schema.SObjectType getSObjectType();

    abstract List<Schema.SObjectField> getAdditionalSObjectFieldList();

    /**
     * Implement this method to inform the base class of the common fields to be queried or listed by the base class methods
     **/
    public virtual List<Schema.SObjectField> getSObjectFieldList()
    {
        List<Schema.SObjectField> workingFieldList = new List<Schema.SObjectField>();
        workingFieldList.addAll( getStandardFields() );
        workingFieldList.addAll( getAdditionalSObjectFieldList() );
        return workingFieldList;
    }

    private List<Schema.SObjectField> getStandardFields()
    {
        List<Schema.SObjectField> standardFields = new List<Schema.SObjectField>();

        for (Schema.SObjectField field : getSObjectType().getDescribe().fields.getMap().values())
        {
            if ( string.valueOf( field ).startsWith('INVALID FIELD')
                || (standardSObjectFieldsNotToIncludeSetBySObjectTYpeMap.containsKey( getSObjectType() )
                    && standardSObjectFieldsNotToIncludeSetBySObjectTYpeMap.get( getSObjectType() ).contains( String.valueOf( field ).toLowerCase() )
                    ))
            {
                system.debug( LoggingLevel.FINEST, 'field : ' + field + ' ignored');
                continue;
            }

            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();

            if ( ! fieldDescribe.isCustom() )
            {
                standardFields.add( field );
                system.debug( LoggingLevel.FINEST, 'field : ' + field + ' added');
            }
            else
            {
                system.debug( LoggingLevel.FINEST, 'field : ' + field + ' ignored');
            }
        }
        return standardFields;
    }

    public ApplicationSObjectSelector addQueryFactoryParentSelect(fflib_QueryFactory parentQueryFactory, Schema.SObjectField relationshipField)
    {
        this.configureQueryFactoryFields( parentQueryFactory, relationshipField.getDescribe().getRelationshipName());

        return this;
    }

    public String selectSObjectsByIdQuery()
    {
        return newQueryFactory().setCondition('id in :idSet').toSOQL();
    }
}