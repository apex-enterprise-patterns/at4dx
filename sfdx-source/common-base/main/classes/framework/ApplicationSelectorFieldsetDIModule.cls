public class ApplicationSelectorFieldsetDIModule
    extends di_Module
{
    public override void configure() 
    {
        Map<SObjectType, Map<String, Schema.FieldSet>> fieldsetMap = new Map<SObjectType, Map<String, Schema.FieldSet>>();

        Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe();

        for (SelectorConfig_FieldSetInclusion__mdt scfi : getConfigurationRecords())
        {
            SObjectType soType = globalDescribeMap.get(scfi.SObjectType__c.toLowerCase());

            if (soType != null)
            {
                if (!fieldsetMap.containsKey(soType))
                {
                    fieldsetMap.put(soType, new Map<String, Schema.FieldSet>());
                    for (Fieldset fs : soType.getDescribe().fieldSets.getMap().values())
                    {
                        fieldsetMap.get(soType).put(fs.getName().toLowerCase(), fs);
                    }
                }
                else
                {
                    System.debug(
                        LoggingLevel.ERROR, 
                        'SelectorConfig_FieldSetInclusion record, ' + scfi.DeveloperName + 
                        ', specifies field set named, ' + scfi.FieldsetName__c + 
                        ', which was not found for SObject Type, ' + scfi.SObjectType__c);
                }
            }
            else
            {
                System.debug(
                    LoggingLevel.ERROR, 
                    'SelectorConfig_FieldSetInclusion record, ' + scfi.DeveloperName + 
                    ', specifies SObject Type, ' + scfi.SObjectType__c +
                    ', but was not found');
            }
        }

        System.debug(
            LoggingLevel.DEBUG,
            getConfigurationRecords() + '\n' +
            globalDescribeMap + '\n' +
            fieldsetMap
        );

        for (SelectorConfig_FieldSetInclusion__mdt scfi : getConfigurationRecords())
        {
            SObjectType soType = globalDescribeMap.get(scfi.SObjectType__c);

            if (!fieldsetMap.containsKey(soType)) continue;
            if (!fieldsetMap.get(soType).containsKey(scfi.FieldsetName__c.toLowerCase())) continue;

            apex();
            bind(globalDescribeMap.get(scfi.SObjectType__c));
            bind(Schema.Fieldset.class);
            data(scfi);
            to(fieldsetMap.get(soType).get(scfi.FieldsetName__c.toLowerCase()).getName());
        }

        System.debug(LoggingLevel.DEBUG, di_Injector.Org.Bindings.get());
    }

    private List<SelectorConfig_FieldSetInclusion__mdt> configurationRecords = null;

    private List<SelectorConfig_FieldSetInclusion__mdt> getConfigurationRecords()
    {
        if (configurationRecords == null)
        {
            configurationRecords =
            [
                select
                    Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, 
                    SObjectType__c, FieldsetName__c
                from SelectorConfig_FieldSetInclusion__mdt
                where IsActive__c = true
                order by SObjectType__c, Fieldsetname__c
            ];
        }

        return configurationRecords;
    }
}
