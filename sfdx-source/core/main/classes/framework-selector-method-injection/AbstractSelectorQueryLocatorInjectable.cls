public abstract class AbstractSelectorQueryLocatorInjectable 
    implements ISelectorQueryLocatorMethodInjectable, ISelectorMethodSetable
{
    private fflib_QueryFactory qf;
    private ISelectorMethodParameterable params;

    protected fflib_QueryFactory newQueryFactory()
    {
        return this.qf;
    }

    public void setQueryFactory( fflib_QueryFactory qf )
    {
        this.qf = qf;
    }

    public void setParameters( ISelectorMethodParameterable params )
    {
        this.params = params;
    }

    protected ISelectorMethodParameterable getParameters()
    {
        return this.params;
    }
}
