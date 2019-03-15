/**
 * Copyright (c) 2018, John M. Daniel
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, 
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, 
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, 
 *      this list of conditions and the following disclaimer in the documentation 
 *      and/or other materials provided with the distribution.
 * - Neither the name of the John M. Daniel, nor the names of its contributors 
 *      may be used to endorse or promote products derived from this software without 
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/

public with sharing class AccountsSelector 
    extends ApplicationSObjectSelector
    implements IAccountsSelector
{
    public static IAccountsSelector newInstance()
    {
        return (IAccountsSelector) Application.Selector.newInstance( Account.SObjectType );
    }

    public Schema.sObjectType getSObjectType()
    {
        return Account.SObjectType;
    }

    public override List<Schema.SObjectField> getSObjectFieldList()
    {
        return new List<Schema.SObjectField> {
            Account.Id,
            Account.Name
        };
    }

    private List<Schema.SObjectField> getAdditionalSObjectFieldList()
    {
        return new List<Schema.SObjectField> { };
    }

    public List<Account> selectById(Set<Id> idSet)
    {
        return (List<Account>) selectSObjectsById( idSet == null ? new Set<Id>() : idSet );
    }

    public List<Account> selectByName( Set<String> nameSet )
    {
        fflib_QueryFactory qf = newQueryFactory();
        
        for (FieldSet fs : sObjectFieldSetList)
        {
            qf.selectFieldSet(fs);
        }

        qf.setCondition( Account.Name + ' in :nameSet');
        return Database.query(qf.toSOQL());
    }
}
