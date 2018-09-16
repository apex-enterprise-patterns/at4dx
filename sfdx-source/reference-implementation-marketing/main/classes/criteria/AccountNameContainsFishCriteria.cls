public class AccountNameContainsFishCriteria
    implements IDomainProcessCriteria
{
    private list<Account> records = new list<Account>();

    public IDomainProcessCriteria setRecordsToEvaluate(List<SObject> records)
    {
        this.records.clear();
        this.records.addAll( (list<Account>)records );

        return this;
    }

    public List<SObject> run()
    {
        list<Account> qualifiedRecords = new list<Account>();

        // Loop through the Account records.
        for ( Account record : this.records )
        {
            // We are only interested in Account records that have the word fish in their name
            if ( record.Name.containsIgnoreCase('fish') )
            {
                qualifiedRecords.add( record );
            }
        }

        return qualifiedRecords;
    }
}
