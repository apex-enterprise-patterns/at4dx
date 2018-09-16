public class DomainProcessInjectionDIModule 
    extends di_Module
{
    public override void configure() 
    {
        system.debug('DomainProcessInjectionDIModule configure() called');
        apex().bind( IDomainProcessCoordinator.class ).to( DomainProcessCoordinator.class );
    }
}
