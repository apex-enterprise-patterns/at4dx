/**
 *  IDomainProcessCriteriaWithExistingRecs
 */
public interface IDomainProcessCriteriaWithExistingRecs
    extends IDomainProcessCriteria
{
    IDomainProcessCriteria setExistingRecords( Map<Id, SObject> existingRecords );
}