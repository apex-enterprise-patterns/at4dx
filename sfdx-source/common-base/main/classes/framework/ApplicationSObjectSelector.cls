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

    private List<Schema.FieldSet> sObjectFieldSetList = null;

    private void incorporateAdditionalSObjectFields()
    {
        Map<String, Schema.FieldSet> fieldSetMap = null;
        for ( SelectorConfig_FieldSetInclusion__mdt customMetadataRecord : getFieldsetInclusionRecords() )
        {
            if ( getSObjectType().getDescribe().getName().equalsIgnoreCase( customMetadataRecord.SObjectType__c ) )
            {
                // find the related fieldset and then add all of those fields to the 
                this.sObjectFieldSetList = new List<Schema.FieldSet>();
                fieldSetMap = getSObjectType().getDescribe().fieldSets.getMap();
                
                if ( fieldSetMap.containsKey( customMetadataRecord.FieldsetName__c.toLowerCase() ) )
                {
                    this.sObjectFieldSetList.add( fieldSetMap.get( customMetadataRecord.FieldsetName__c ) );
                }
                else 
                {
                    System.debug(
                        LoggingLevel.ERROR, 'SelectorConfig_FieldSetInclusion__mdt record ' + customMetadataRecord.FieldsetName__c + 
                        ' specifies field set of ' + customMetadataRecord.FieldsetName__c + ' which was not found.');
                }
            }
            else 
            {
                System.debug(
                    LoggingLevel.ERROR, 'SelectorConfig_FieldSetInclusion__mdt record ' + customMetadataRecord.FieldsetName__c + 
                    ' specifies SObjectType__c of ' + customMetadataRecord.SObjectType__c + ' which was not found.');
            }
        }
    }

    public ApplicationSObjectSelector() {
        this(false);
        incorporateAdditionalSObjectFields();
    }
    
    public ApplicationSObjectSelector(Boolean includeFieldSetFields) {
        // Disable the base class read security checking in preference to explicit checking elsewhere        
        this(includeFieldSetFields, false, false);
        incorporateAdditionalSObjectFields();
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

    private List<SelectorConfig_FieldSetInclusion__mdt> getFieldsetInclusionRecords()
    {
        return
        [
            select
                Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, 
                SObjectType__c, FieldsetName__c, IsActive__c
            from SelectorConfig_FieldSetInclusion__mdt
            where IsActive__c = true and SObjectType__c = :this.getSObjectType().getDescribe().getName()
        ];
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