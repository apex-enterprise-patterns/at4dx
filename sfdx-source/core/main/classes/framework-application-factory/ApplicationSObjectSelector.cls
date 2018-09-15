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

        for ( di_Binding binding : di_Injector.Org.Bindings
                                                    .byName(Schema.FieldSet.class.getName())
                                                    .bySObject(getSObjectType())
                                                    .get()
        )
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
    
    // public ApplicationSObjectSelector(Boolean includeFieldSetFields) {
    //     // Disable the base class read security checking in preference to explicit checking elsewhere        
    //     this(includeFieldSetFields, false, false);
    // }
    
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