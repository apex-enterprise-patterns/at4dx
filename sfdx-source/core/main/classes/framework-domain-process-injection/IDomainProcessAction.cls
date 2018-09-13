/**
 *  IDomainProcessAction
 */
public interface IDomainProcessAction
{
    IDomainProcessAction setRecordsToActOn( List<SObject> recordsToActOn );
    Boolean run();
}