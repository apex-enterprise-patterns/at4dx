/**
 *
 * di_Module based class used to manage the Application Factory mappings of for the SOBject
 */
public class ApplicationSObjectUnitOfWorkDIModule 
    extends di_Module
{
    public override void configure() 
    {
        apex().bind( IApplicationSObjectUnitOfWork.class ).to( ApplicationSObjectUnitOfWorkDIProvider.class );
    }
}
