/**
 *  IDomainProcessCriteria
 */
public interface IDomainProcessCriteria
{
    IDomainProcessCriteria setRecordsToEvaluate( list<SObject> records );
    list<Sobject> run();
}