public interface IContactsSelector 
    extends IApplicationSObjectSelector
{
    List<Contact> selectById( Set<Id> idSet );
    List<Contact> selectByName( Set<String> nameSet );
}
