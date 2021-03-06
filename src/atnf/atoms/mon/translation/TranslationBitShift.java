//
// Copyright (C) CSIRO Australia Telescope National Facility
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Library General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.

package atnf.atoms.mon.translation;

import org.apache.log4j.Logger;

import atnf.atoms.mon.PointData;
import atnf.atoms.mon.PointDescription;

/**
 * This class can extract specific bits from a binary word. The first <i>init</i>
 * argument is an integer value to bitwise AND with the raw value. The second
 * argument is the number of bits to right shift the data after performing the
 * AND.
 * 
 * <P>
 * Note this class can only perform the translation when the raw data is a
 * <i>Number</i>. In reality the data should be an integer numeric type.
 * 
 * @author David Brodrick
 * @version $Id: TranslationBitShift.java,v 1.3 2005/07/18 23:56:37 bro764 Exp $
 */
public class TranslationBitShift extends Translation
{
  /** Required arguments. */
  protected static String itsArgs[] = new String[] { "BitShift Translation", "BitShift", "AND-Mask", "java.lang.String",
      "Shift Positions", "java.lang.String" };

  /** Number to bitwise AND with the raw value. */
  protected int itsAndMask = 0;

  /** Number of bits to left shift the value after ANDing it. */
  protected int itsNumShift = 0;

  public TranslationBitShift(PointDescription parent, String[] init)
  {
    super(parent, init);
    // Parse scale and offset from the argument strings
    if (init.length == 2) {
      if (init[0].startsWith("0x")) {
        itsAndMask = Integer.parseInt(init[0].substring(2), 16);
      } else {
        itsAndMask = Integer.parseInt(init[0]);
      }
      itsNumShift = Integer.parseInt(init[1]);
    }
  }

  /** Perform the actual data translation. */
  public PointData translate(PointData data)
  {
    // Ensure there is raw data for us to translate!
    if (data == null || data.getData() == null) {
      return null;
    }

    Object d = data.getData();
    if (d instanceof Number) {
      // Get the bits
      int temp = ((Number) d).intValue();
      // Perform the bitwise AND
      temp = temp & itsAndMask;
      // Shift the correct number of places
      temp = temp >> itsNumShift;
      // Translation is now complete
      return new PointData(itsParent.getFullName(), data.getTimestamp(), new Integer(temp), data.getAlarm());
    } else {
      // We can only translate Numbers using this class
      Logger logger = Logger.getLogger(this.getClass().getName());
      logger.error("Non-Numeric type for " + data.getName());
      return null;
    }
  }

  public static String[] getArgs()
  {
    return itsArgs;
  }
}
