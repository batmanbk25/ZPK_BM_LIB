FUNCTION ZFM_DATA_UNESCAPE_HTML.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  CHANGING
*"     REFERENCE(C_HTML) TYPE  STRING
*"----------------------------------------------------------------------
  DATA:
    LW_PATTERN                TYPE STRING,
    LW_REPLACE                TYPE STRING,
    LW_START                  TYPE I,
    LW_I                      TYPE I,
    LW_LENGTH                 TYPE I,
    LW_CONTENT                TYPE STRING.

  CHECK C_HTML CP '*&*;*'.

* Unescape the essential thing
  REPLACE ALL OCCURRENCES OF '&quot;'   IN C_HTML WITH '"'.
  REPLACE ALL OCCURRENCES OF '&lt;'     IN C_HTML WITH '<'.
  REPLACE ALL OCCURRENCES OF '&gt;'     IN C_HTML WITH '>'.
  REPLACE ALL OCCURRENCES OF '&amp;'    IN C_HTML WITH '&'.
  REPLACE ALL OCCURRENCES OF '&euro;'   IN C_HTML WITH ''.
  REPLACE ALL OCCURRENCES OF '&dagger;' IN C_HTML WITH '#'.
  REPLACE ALL OCCURRENCES OF '&Dagger;' IN C_HTML WITH '#'.

* Escape the &#number;
  IF C_HTML CS '&#'.
    LW_START = 1.
    DO.
      SEARCH C_HTML FOR '&#' IN CHARACTER MODE STARTING AT LW_START.
      IF SY-SUBRC = 0.
        LW_START = LW_START + SY-FDPOS.
        SEARCH C_HTML FOR ';' IN CHARACTER MODE STARTING AT LW_START.
        IF SY-SUBRC = 0.
          SUBTRACT 1 FROM LW_START.
          LW_LENGTH = SY-FDPOS + 1.
          LW_PATTERN = C_HTML+LW_START(LW_LENGTH).
          ADD 2 TO LW_START.
          LW_LENGTH = SY-FDPOS - 2.
          LW_CONTENT = C_HTML+LW_START(LW_LENGTH).
          IF LW_CONTENT CO ' 0123456789'.
            LW_I = LW_CONTENT.
            TRY.
                LW_REPLACE = CL_ABAP_CONV_IN_CE=>UCCPI( LW_I ).
              CATCH CX_ROOT.
                LW_REPLACE = '#'.
            ENDTRY.
            REPLACE ALL OCCURRENCES OF LW_PATTERN
              IN C_HTML WITH LW_REPLACE.
          ENDIF.
        ELSE.
          EXIT.
        ENDIF.
      ELSE.
        EXIT.
      ENDIF.
    ENDDO.
  ENDIF.

  CHECK C_HTML CP '*&*;*'.
  PERFORM UNESCAPE_AMP:
    USING '&nbsp;'    160 CHANGING C_HTML,
    USING '&iexcl;'   161 CHANGING C_HTML,
    USING '&cent;'    162 CHANGING C_HTML,
    USING '&pound;'   163 CHANGING C_HTML,
    USING '&curren;'  164 CHANGING C_HTML,
    USING '&yen;'     165 CHANGING C_HTML,
    USING '&brvbar;'  166 CHANGING C_HTML,
    USING '&sect;'    167 CHANGING C_HTML,
    USING '&uml;'     168 CHANGING C_HTML,
    USING '&copy;'    169 CHANGING C_HTML,
    USING '&ordf;'    170 CHANGING C_HTML,
    USING '&laquo;'   171 CHANGING C_HTML,
    USING '&not;'     172 CHANGING C_HTML,
    USING '&shy;'     173 CHANGING C_HTML,
    USING '&reg;'     174 CHANGING C_HTML,
    USING '&macr;'    175 CHANGING C_HTML,
    USING '&deg;'     176 CHANGING C_HTML,
    USING '&plusmn;'  177 CHANGING C_HTML,
    USING '&sup2;'    178 CHANGING C_HTML,
    USING '&sup3;'    179 CHANGING C_HTML,
    USING '&acute;'   180 CHANGING C_HTML,
    USING '&micro;'   181 CHANGING C_HTML,
    USING '&para;'    182 CHANGING C_HTML,
    USING '&middot;'  183 CHANGING C_HTML,
    USING '&cedil;'   184 CHANGING C_HTML,
    USING '&sup1;'    185 CHANGING C_HTML.
  CHECK C_HTML CP '*&*;*'.
  PERFORM UNESCAPE_AMP:
    USING '&ordm;'    186 CHANGING C_HTML,
    USING '&raquo;'   187 CHANGING C_HTML,
    USING '&frac14;'  188 CHANGING C_HTML,
    USING '&frac12;'  189 CHANGING C_HTML,
    USING '&frac34;'  190 CHANGING C_HTML,
    USING '&iquest;'  191 CHANGING C_HTML,
    USING '&Agrave;'  192 CHANGING C_HTML,
    USING '&Aacute;'  193 CHANGING C_HTML,
    USING '&Acirc;'   194 CHANGING C_HTML,
    USING '&Atilde;'  195 CHANGING C_HTML,
    USING '&Auml;'    196 CHANGING C_HTML,
    USING '&Aring;'   197 CHANGING C_HTML,
    USING '&AElig;'   198 CHANGING C_HTML,
    USING '&Ccedil;'  199 CHANGING C_HTML,
    USING '&Egrave;'  200 CHANGING C_HTML,
    USING '&Eacute;'  201 CHANGING C_HTML,
    USING '&Ecirc;'   202 CHANGING C_HTML,
    USING '&Euml;'    203 CHANGING C_HTML,
    USING '&Igrave;'  204 CHANGING C_HTML,
    USING '&Iacute;'  205 CHANGING C_HTML,
    USING '&Icirc;'   206 CHANGING C_HTML,
    USING '&Iuml;'    207 CHANGING C_HTML.
  CHECK C_HTML CP '*&*;*'.
  PERFORM UNESCAPE_AMP:
    USING '&ETH;'     208 CHANGING C_HTML,
    USING '&Ntilde;'  209 CHANGING C_HTML,
    USING '&Ograve;'  210 CHANGING C_HTML,
    USING '&Oacute;'  211 CHANGING C_HTML,
    USING '&Ocirc;'   212 CHANGING C_HTML,
    USING '&Otilde;'  213 CHANGING C_HTML,
    USING '&Ouml;'    214 CHANGING C_HTML,
    USING '&times;'   215 CHANGING C_HTML,
    USING '&Oslash;'  216 CHANGING C_HTML,
    USING '&Ugrave;'  217 CHANGING C_HTML,
    USING '&Uacute;'  218 CHANGING C_HTML,
    USING '&Ucirc;'   219 CHANGING C_HTML,
    USING '&Uuml;'    220 CHANGING C_HTML,
    USING '&Yacute;'  221 CHANGING C_HTML,
    USING '&THORN;'   222 CHANGING C_HTML,
    USING '&szlig;'   223 CHANGING C_HTML,
    USING '&agrave;'  224 CHANGING C_HTML,
    USING '&aacute;'  225 CHANGING C_HTML,
    USING '&acirc;'   226 CHANGING C_HTML.
  CHECK C_HTML CP '*&*;*'.
  PERFORM UNESCAPE_AMP:
    USING '&atilde;'  227 CHANGING C_HTML,
    USING '&auml;'    228 CHANGING C_HTML,
    USING '&aring;'   229 CHANGING C_HTML,
    USING '&aelig;'   230 CHANGING C_HTML,
    USING '&ccedil;'  231 CHANGING C_HTML,
    USING '&egrave;'  232 CHANGING C_HTML,
    USING '&eacute;'  233 CHANGING C_HTML,
    USING '&ecirc;'   234 CHANGING C_HTML,
    USING '&euml;'    235 CHANGING C_HTML,
    USING '&igrave;'  236 CHANGING C_HTML,
    USING '&iacute;'  237 CHANGING C_HTML,
    USING '&icirc;'   238 CHANGING C_HTML,
    USING '&iuml;'    239 CHANGING C_HTML,
    USING '&eth;'     240 CHANGING C_HTML,
    USING '&ntilde;'  241 CHANGING C_HTML,
    USING '&ograve;'  242 CHANGING C_HTML,
    USING '&oacute;'  243 CHANGING C_HTML.
  CHECK C_HTML CP '*&*;*'.
  PERFORM UNESCAPE_AMP:
    USING '&ocirc;'   244 CHANGING C_HTML,
    USING '&otilde;'  245 CHANGING C_HTML,
    USING '&ouml;'    246 CHANGING C_HTML,
    USING '&divide;'  247 CHANGING C_HTML,
    USING '&oslash;'  248 CHANGING C_HTML,
    USING '&ugrave;'  249 CHANGING C_HTML,
    USING '&uacute;'  250 CHANGING C_HTML,
    USING '&ucirc;'   251 CHANGING C_HTML,
    USING '&uuml;'    252 CHANGING C_HTML,
    USING '&yacute;'  253 CHANGING C_HTML,
    USING '&thorn;'   254 CHANGING C_HTML,
    USING '&yuml;'    255 CHANGING C_HTML,
    USING '&fnof;'    402 CHANGING C_HTML,
    USING '&Alpha;'   913 CHANGING C_HTML,
    USING '&Beta;'    914 CHANGING C_HTML,
    USING '&Gamma;'   915 CHANGING C_HTML,
    USING '&Delta;'   916 CHANGING C_HTML,
    USING '&Epsilon;' 917 CHANGING C_HTML,
    USING '&Zeta;'    918 CHANGING C_HTML.
  CHECK C_HTML CP '*&*;*'.
  PERFORM UNESCAPE_AMP:
    USING '&Eta;'     919 CHANGING C_HTML,
    USING '&Theta;'   920 CHANGING C_HTML,
    USING '&Iota;'    921 CHANGING C_HTML,
    USING '&Kappa;'   922 CHANGING C_HTML,
    USING '&Lambda;'  923 CHANGING C_HTML,
    USING '&Mu;'      924 CHANGING C_HTML,
    USING '&Nu;'      925 CHANGING C_HTML,
    USING '&Xi;'      926 CHANGING C_HTML,
    USING '&Omicron;' 927 CHANGING C_HTML,
    USING '&Pi;'      928 CHANGING C_HTML,
    USING '&Rho;'     929 CHANGING C_HTML,
    USING '&Sigma;'   931 CHANGING C_HTML,
    USING '&Tau;'     932 CHANGING C_HTML,
    USING '&Upsilon;' 933 CHANGING C_HTML.
  CHECK C_HTML CP '*&*;*'.
  PERFORM UNESCAPE_AMP:
    USING '&Phi;'     934 CHANGING C_HTML,
    USING '&Chi;'     935 CHANGING C_HTML,
    USING '&Psi;'     936 CHANGING C_HTML,
    USING '&Omega;'   937 CHANGING C_HTML,
    USING '&alpha;'   945 CHANGING C_HTML,
    USING '&beta;'    946 CHANGING C_HTML,
    USING '&gamma;'   947 CHANGING C_HTML,
    USING '&delta;'   948 CHANGING C_HTML,
    USING '&epsilon;' 949 CHANGING C_HTML,
    USING '&zeta;'    950 CHANGING C_HTML,
    USING '&eta;'     951 CHANGING C_HTML,
    USING '&theta;'   952 CHANGING C_HTML,
    USING '&iota;'    953 CHANGING C_HTML,
    USING '&kappa;'   954 CHANGING C_HTML,
    USING '&lambda;'  955 CHANGING C_HTML,
    USING '&mu;'      956 CHANGING C_HTML,
    USING '&nu;'      957 CHANGING C_HTML.
  CHECK C_HTML CP '*&*;*'.
  PERFORM UNESCAPE_AMP:
    USING '&xi;'      958 CHANGING C_HTML,
    USING '&omicron;' 959 CHANGING C_HTML,
    USING '&pi;'      960 CHANGING C_HTML,
    USING '&rho;'     961 CHANGING C_HTML,
    USING '&sigmaf;'  962 CHANGING C_HTML,
    USING '&sigma;'   963 CHANGING C_HTML,
    USING '&tau;'     964 CHANGING C_HTML,
    USING '&upsilon;' 965 CHANGING C_HTML,
    USING '&phi;'     966 CHANGING C_HTML,
    USING '&chi;'     967 CHANGING C_HTML,
    USING '&psi;'     968 CHANGING C_HTML,
    USING '&omega;'   969 CHANGING C_HTML,
    USING '&thetasym;' 977 CHANGING C_HTML,
    USING '&upsih;'   978 CHANGING C_HTML,
    USING '&piv;'     982 CHANGING C_HTML,
    USING '&bull;'    8226 CHANGING C_HTML,
    USING '&hellip;'  8230 CHANGING C_HTML,
    USING '&prime;'   8242 CHANGING C_HTML.
  CHECK C_HTML CP '*&*;*'.
  PERFORM UNESCAPE_AMP:
    USING '&Prime;'   8243 CHANGING C_HTML,
    USING '&oline;'   8254 CHANGING C_HTML,
    USING '&frasl;'   8260 CHANGING C_HTML,
    USING '&weierp;'  8472 CHANGING C_HTML,
    USING '&image;'   8465 CHANGING C_HTML,
    USING '&real;'    8476 CHANGING C_HTML,
    USING '&trade;'   8482 CHANGING C_HTML,
    USING '&alefsym;' 8501 CHANGING C_HTML,
    USING '&larr;'    8592 CHANGING C_HTML,
    USING '&uarr;'    8593 CHANGING C_HTML,
    USING '&rarr;'    8594 CHANGING C_HTML,
    USING '&darr;'    8595 CHANGING C_HTML,
    USING '&harr;'    8596 CHANGING C_HTML,
    USING '&crarr;'   8629 CHANGING C_HTML,
    USING '&lArr;'    8656 CHANGING C_HTML,
    USING '&uArr;'    8657 CHANGING C_HTML,
    USING '&rArr;'    8658 CHANGING C_HTML,
    USING '&dArr;'    8659 CHANGING C_HTML,
    USING '&hArr;'    8660 CHANGING C_HTML.
  CHECK C_HTML CP '*&*;*'.
  PERFORM UNESCAPE_AMP:
    USING '&forall;'  8704 CHANGING C_HTML,
    USING '&part;'    8706 CHANGING C_HTML,
    USING '&exist;'   8707 CHANGING C_HTML,
    USING '&empty;'   8709 CHANGING C_HTML,
    USING '&nabla;'   8711 CHANGING C_HTML,
    USING '&isin;'    8712 CHANGING C_HTML,
    USING '&notin;'   8713 CHANGING C_HTML,
    USING '&ni;'      8715 CHANGING C_HTML,
    USING '&prod;'    8719 CHANGING C_HTML,
    USING '&sum;'     8721 CHANGING C_HTML,
    USING '&minus;'   8722 CHANGING C_HTML,
    USING '&lowast;'  8727 CHANGING C_HTML,
    USING '&radic;'   8730 CHANGING C_HTML,
    USING '&prop;'    8733 CHANGING C_HTML,
    USING '&infin;'   8734 CHANGING C_HTML.
  CHECK C_HTML CP '*&*;*'.
  PERFORM UNESCAPE_AMP:
    USING '&ang;'     8736 CHANGING C_HTML,
    USING '&and;'     8743 CHANGING C_HTML,
    USING '&or;'      8744 CHANGING C_HTML,
    USING '&cap;'     8745 CHANGING C_HTML,
    USING '&cup;'     8746 CHANGING C_HTML,
    USING '&int;'     8747 CHANGING C_HTML,
    USING '&there4;'  8756 CHANGING C_HTML,
    USING '&sim;'     8764 CHANGING C_HTML,
    USING '&cong;'    8773 CHANGING C_HTML,
    USING '&asymp;'   8776 CHANGING C_HTML,
    USING '&ne;'      8800 CHANGING C_HTML,
    USING '&equiv;'   8801 CHANGING C_HTML,
    USING '&le;'      8804 CHANGING C_HTML,
    USING '&ge;'      8805 CHANGING C_HTML,
    USING '&sub;'     8834 CHANGING C_HTML,
    USING '&sup;'     8835 CHANGING C_HTML,
    USING '&nsub;'    8836 CHANGING C_HTML,
    USING '&sube;'    8838 CHANGING C_HTML,
    USING '&supe;'    8839 CHANGING C_HTML,
    USING '&oplus;'   8853 CHANGING C_HTML.
  CHECK C_HTML CP '*&*;*'.
  PERFORM UNESCAPE_AMP:
    USING '&otimes;'  8855 CHANGING C_HTML,
    USING '&perp;'    8869 CHANGING C_HTML,
    USING '&sdot;'    8901 CHANGING C_HTML,
    USING '&lceil;'   8968 CHANGING C_HTML,
    USING '&rceil;'   8969 CHANGING C_HTML,
    USING '&lfloor;'  8970 CHANGING C_HTML,
    USING '&rfloor;'  8971 CHANGING C_HTML,
    USING '&lang;'    9001 CHANGING C_HTML,
    USING '&rang;'    9002 CHANGING C_HTML,
    USING '&loz;'     9674 CHANGING C_HTML,
    USING '&spades;'  9824 CHANGING C_HTML,
    USING '&clubs;'   9827 CHANGING C_HTML,
    USING '&hearts;'  9829 CHANGING C_HTML,
    USING '&diams;'   9830 CHANGING C_HTML,
    USING '&quot;'    34 CHANGING C_HTML,
    USING '&amp;'     38 CHANGING C_HTML,
    USING '&lt;'      60 CHANGING C_HTML,
    USING '&gt;'      62 CHANGING C_HTML,
    USING '&OElig;'   338 CHANGING C_HTML,
    USING '&oelig;'   339 CHANGING C_HTML.
  CHECK C_HTML CP '*&*;*'.
  PERFORM UNESCAPE_AMP:
    USING '&Scaron;'  352 CHANGING C_HTML,
    USING '&scaron;'  353 CHANGING C_HTML,
    USING '&Yuml;'    376 CHANGING C_HTML,
    USING '&circ;'    710 CHANGING C_HTML,
    USING '&tilde;'   732 CHANGING C_HTML,
    USING '&ensp;'    8194 CHANGING C_HTML,
    USING '&emsp;'    8195 CHANGING C_HTML,
    USING '&thinsp;'  8201 CHANGING C_HTML,
    USING '&zwnj;'    8204 CHANGING C_HTML,
    USING '&zwj;'     8205 CHANGING C_HTML,
    USING '&lrm;'     8206 CHANGING C_HTML,
    USING '&rlm;'     8207 CHANGING C_HTML,
    USING '&ndash;'   8211 CHANGING C_HTML.
  CHECK C_HTML CP '*&*;*'.
  PERFORM UNESCAPE_AMP:
    USING '&mdash;'   8212 CHANGING C_HTML,
    USING '&lsquo;'   8216 CHANGING C_HTML,
    USING '&rsquo;'   8217 CHANGING C_HTML,
    USING '&sbquo;'   8218 CHANGING C_HTML,
    USING '&ldquo;'   8220 CHANGING C_HTML,
    USING '&rdquo;'   8221 CHANGING C_HTML,
    USING '&bdquo;'   8222 CHANGING C_HTML,
    USING '&dagger;'  8224 CHANGING C_HTML,
    USING '&Dagger;'  8225 CHANGING C_HTML,
    USING '&permil;'  8240 CHANGING C_HTML,
    USING '&lsaquo;'  8249 CHANGING C_HTML,
    USING '&rsaquo;'  8250 CHANGING C_HTML,
    USING '&euro;'    8364 CHANGING C_HTML.

ENDFUNCTION.
