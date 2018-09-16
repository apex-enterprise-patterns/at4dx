public class ApplicationSelectorFieldsetDIModule
    extends di_Module
{
    private static Map<SObjectType, Set<String>> FIELDSETNAMES_BY_SOBJECTTYPE_MAP;

    static 
    {
        FIELDSETNAMES_BY_SOBJECTTYPE_MAP = new Map<SObjectType, Set<String>>();

        Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe();

        SObjectType soType = null;

        for (SelectorConfig_FieldSetInclusion__mdt scfi : [select Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName
                                                            , SObjectType__c, FieldsetName__c
                                                         from SelectorConfig_FieldSetInclusion__mdt
                                                        where IsActive__c = true
                                                        order by SObjectType__c, Fieldsetname__c] )
        {
            soType = globalDescribeMap.get(scfi.SObjectType__c.toLowerCase());

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
