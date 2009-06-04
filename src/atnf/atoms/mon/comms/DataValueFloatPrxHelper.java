// **********************************************************************
//
// Copyright (c) 2003-2008 ZeroC, Inc. All rights reserved.
//
// This copy of Ice is licensed to you under the terms described in the
// ICE_LICENSE file included in this distribution.
//
// **********************************************************************

// Ice version 3.3.0

package atnf.atoms.mon.comms;

public final class DataValueFloatPrxHelper extends Ice.ObjectPrxHelperBase implements DataValueFloatPrx
{
    public static DataValueFloatPrx
    checkedCast(Ice.ObjectPrx __obj)
    {
        DataValueFloatPrx __d = null;
        if(__obj != null)
        {
            try
            {
                __d = (DataValueFloatPrx)__obj;
            }
            catch(ClassCastException ex)
            {
                if(__obj.ice_isA("::atnf::atoms::mon::comms::DataValueFloat"))
                {
                    DataValueFloatPrxHelper __h = new DataValueFloatPrxHelper();
                    __h.__copyFrom(__obj);
                    __d = __h;
                }
            }
        }
        return __d;
    }

    public static DataValueFloatPrx
    checkedCast(Ice.ObjectPrx __obj, java.util.Map<String, String> __ctx)
    {
        DataValueFloatPrx __d = null;
        if(__obj != null)
        {
            try
            {
                __d = (DataValueFloatPrx)__obj;
            }
            catch(ClassCastException ex)
            {
                if(__obj.ice_isA("::atnf::atoms::mon::comms::DataValueFloat", __ctx))
                {
                    DataValueFloatPrxHelper __h = new DataValueFloatPrxHelper();
                    __h.__copyFrom(__obj);
                    __d = __h;
                }
            }
        }
        return __d;
    }

    public static DataValueFloatPrx
    checkedCast(Ice.ObjectPrx __obj, String __facet)
    {
        DataValueFloatPrx __d = null;
        if(__obj != null)
        {
            Ice.ObjectPrx __bb = __obj.ice_facet(__facet);
            try
            {
                if(__bb.ice_isA("::atnf::atoms::mon::comms::DataValueFloat"))
                {
                    DataValueFloatPrxHelper __h = new DataValueFloatPrxHelper();
                    __h.__copyFrom(__bb);
                    __d = __h;
                }
            }
            catch(Ice.FacetNotExistException ex)
            {
            }
        }
        return __d;
    }

    public static DataValueFloatPrx
    checkedCast(Ice.ObjectPrx __obj, String __facet, java.util.Map<String, String> __ctx)
    {
        DataValueFloatPrx __d = null;
        if(__obj != null)
        {
            Ice.ObjectPrx __bb = __obj.ice_facet(__facet);
            try
            {
                if(__bb.ice_isA("::atnf::atoms::mon::comms::DataValueFloat", __ctx))
                {
                    DataValueFloatPrxHelper __h = new DataValueFloatPrxHelper();
                    __h.__copyFrom(__bb);
                    __d = __h;
                }
            }
            catch(Ice.FacetNotExistException ex)
            {
            }
        }
        return __d;
    }

    public static DataValueFloatPrx
    uncheckedCast(Ice.ObjectPrx __obj)
    {
        DataValueFloatPrx __d = null;
        if(__obj != null)
        {
            try
            {
                __d = (DataValueFloatPrx)__obj;
            }
            catch(ClassCastException ex)
            {
                DataValueFloatPrxHelper __h = new DataValueFloatPrxHelper();
                __h.__copyFrom(__obj);
                __d = __h;
            }
        }
        return __d;
    }

    public static DataValueFloatPrx
    uncheckedCast(Ice.ObjectPrx __obj, String __facet)
    {
        DataValueFloatPrx __d = null;
        if(__obj != null)
        {
            Ice.ObjectPrx __bb = __obj.ice_facet(__facet);
            DataValueFloatPrxHelper __h = new DataValueFloatPrxHelper();
            __h.__copyFrom(__bb);
            __d = __h;
        }
        return __d;
    }

    protected Ice._ObjectDelM
    __createDelegateM()
    {
        return new _DataValueFloatDelM();
    }

    protected Ice._ObjectDelD
    __createDelegateD()
    {
        return new _DataValueFloatDelD();
    }

    public static void
    __write(IceInternal.BasicStream __os, DataValueFloatPrx v)
    {
        __os.writeProxy(v);
    }

    public static DataValueFloatPrx
    __read(IceInternal.BasicStream __is)
    {
        Ice.ObjectPrx proxy = __is.readProxy();
        if(proxy != null)
        {
            DataValueFloatPrxHelper result = new DataValueFloatPrxHelper();
            result.__copyFrom(proxy);
            return result;
        }
        return null;
    }
}