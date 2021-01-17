/*
 * A simple test program to check that at least the default core font works.
 *
 * To build and run:
 *
 *        javac Fonts.java
 *        java Fonts
 */
import java.awt.*;
import java.awt.Image;
import java.awt.image.BufferedImage;

public class Fonts
{
    public static void main(String[] args) throws Exception
    {
        Font defaultFont = Font.decode(null);
        System.out.println(defaultFont);

        GraphicsEnvironment g =
            GraphicsEnvironment.getLocalGraphicsEnvironment();

        String fonts[] = g.getAvailableFontFamilyNames();

        for (int i = 0; i < fonts.length; i++)
                System.out.println(fonts[i]);

        BufferedImage img = new BufferedImage(640, 480,
            BufferedImage.TYPE_INT_ARGB);
        img.getGraphics().drawString("omnios.org", 20, 20);

    }
}
