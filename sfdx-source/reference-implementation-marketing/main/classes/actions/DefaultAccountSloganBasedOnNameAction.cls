public class DefaultAccountSloganBasedOnNameAction 
    extends DomainProcessAbstractAction
{
    public override void runInProcess()
    {
        Account accountRecord = null;

        for ( SObject record : this.records )
        {
            accountRecord = (Account)record;
            accountRecord.Slogan__c = accountRecord.name + ' is a fishy business';
        }
    }
}
