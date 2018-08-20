/**
 *  IApplicationSObjectSelector
 */
public interface IApplicationSObjectSelector 
    extends fflib_ISObjectSelector
{
    /**
     * Returns the SelectSObjectsById(Set<Id>) query string.  Useful for Database.Querylocators
     */
    String selectSObjectsByIdQuery();
}