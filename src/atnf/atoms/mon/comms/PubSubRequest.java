// **********************************************************************
//
// Copyright (c) 2003-2013 ZeroC, Inc. All rights reserved.
//
// This copy of Ice is licensed to you under the terms described in the
// ICE_LICENSE file included in this distribution.
//
// **********************************************************************
//
// Ice version 3.5.0
//
// <auto-generated>
//
// Generated from file `MoniCA.ice'
//
// Warning: do not edit this file.
//
// </auto-generated>
//

package atnf.atoms.mon.comms;

public class PubSubRequest implements java.lang.Cloneable, java.io.Serializable
{
    public String topicname;

    public String[] pointnames;

    public PubSubRequest()
    {
    }

    public PubSubRequest(String topicname, String[] pointnames)
    {
        this.topicname = topicname;
        this.pointnames = pointnames;
    }

    public boolean
    equals(java.lang.Object rhs)
    {
        if(this == rhs)
        {
            return true;
        }
        PubSubRequest _r = null;
        if(rhs instanceof PubSubRequest)
        {
            _r = (PubSubRequest)rhs;
        }

        if(_r != null)
        {
            if(topicname != _r.topicname)
            {
                if(topicname == null || _r.topicname == null || !topicname.equals(_r.topicname))
                {
                    return false;
                }
            }
            if(!java.util.Arrays.equals(pointnames, _r.pointnames))
            {
                return false;
            }

            return true;
        }

        return false;
    }

    public int
    hashCode()
    {
        int __h = 5381;
        __h = IceInternal.HashUtil.hashAdd(__h, "::atnf::atoms::mon::comms::PubSubRequest");
        __h = IceInternal.HashUtil.hashAdd(__h, topicname);
        __h = IceInternal.HashUtil.hashAdd(__h, pointnames);
        return __h;
    }

    public java.lang.Object
    clone()
    {
        java.lang.Object o = null;
        try
        {
            o = super.clone();
        }
        catch(CloneNotSupportedException ex)
        {
            assert false; // impossible
        }
        return o;
    }

    public void
    __write(IceInternal.BasicStream __os)
    {
        __os.writeString(topicname);
        stringarrayHelper.write(__os, pointnames);
    }

    public void
    __read(IceInternal.BasicStream __is)
    {
        topicname = __is.readString();
        pointnames = stringarrayHelper.read(__is);
    }

    public static final long serialVersionUID = -591446952114472307L;
}
