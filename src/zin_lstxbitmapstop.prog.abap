***include rstxdata.
include rstxbool.          " Boolean type and constants
include rstxdataitf.       " Special characters and strings in ITF
include rstxdatatexts.     " Text administration and text interface
include rstxdatabmp.       " Bitmap constants
include rstxdataunits.     " Units
include rstxdataotf.       " OTF-ID's (PrintControl)

tables: rstxu, rsscg,          " Screen fields
        itcth, rlgrap, stxh,
        pstxt.                 " SPA/GPA
tables: ttxob, ttxid, ttxgr.                                 "#EC NEEDED
tables: stxbitmaps.            "BDS bitmaps

type-pools: shlp,              " for Help functions
            sbdst.             " for BDS functions

include lstxbitmapssel.        " selection screens

*************************************************************
* SAPscript bitmap utility functions
*************************************************************
constants:
      c_otf_rd_otfbitma(16)              value '4F54466269746D61',
      c_otf_rd_ff                 type x value 'FF',
      c_otf_rd_formatid_bmon      type x value '01',
      c_otf_rd_formatid_bcol      type x value '02',
      c_otf_rd_subformatid_none   type x value '00',
      c_otf_rd_subformatid_bds    type x value '01',
      c_otf_rd_formatpar1_nonresi type x value '00',
      c_otf_rd_formatpar1_resi    type x value '01',
      c_otf_rd_formatpar1_hi_nocomp type x value '00',
      c_otf_rd_formatpar1_hi_runl   type x value '10',
      c_otf_rd_formatpar2_none    type x value '00',
      c_otf_rd_imageid_len        type i value 90,
      c_bm_format_itf(3)          type c value 'ITF',
      c_bm_format_bmp(3)          type c value 'BMP',
      c_bm_format_bds(3)          type c value 'BDS',
      c_itf_tline_len             type i value 132,
      c_itf_format_cmd(2)         type c value '/:',
      c_itf_format_cmnt(2)        type c value '/*',
      c_itf_format_datl(2)        type c value '/=',
      c_itf_hex_hex(3)            type c value 'HEX',
      c_itf_hex_endhex(6)         type c value 'ENDHEX',
      c_itf_hex_height(6)         type c value 'HEIGHT',
      c_itf_hex_cm(2)             type c value 'CM',
      c_itf_hex_mm(2)             type c value 'MM',
      c_itf_hex_point(2)          type c value 'PT',
      c_itf_hex_twip(2)           type c value 'TW',
      c_itf_hex_type(4)           type c value 'TYPE',
      c_itf_hex_bmon(4)           type c value 'BMON',
      c_itf_hex_bcol(4)           type c value 'BCOL',
      c_itf_hex_resi(4)           type c value 'RESI',
      c_bmp_compr_rgb             type i value 0,
      c_bmp_compr_rle8            type i value 1,
      c_bmp_compr_rle4            type i value 2,
      c_bmp_compr_bitfields       type i value 3.
data: begin of otf_bminfo,
        bmtype(4)     type c,
        new_rd_format type ty_boolean,
        is_monochrome type ty_boolean,
        is_resident   type ty_boolean,
        w_tw          type i,
        h_tw          type i,
        w_pix         type i,
        h_pix         type i,
        dpi           type i,
        bitsperpix    type i,
        coltabsize    type i,
        numdatabytes  type i,
        autoheight    type ty_boolean,
        res_h_tw      type i,
        bytes_per_row type i,
        bytes_per_row_act type i,
        bytes_per_row_fullcolor type i,
        is_compressed type ty_boolean,
      end of otf_bminfo.
constants:
      c_bm_file_linelen     type i value 80.
data: bm_file_lineofs type i.
data: begin of bm_file occurs 0,
        l(80) type x,
      end of bm_file.
constants:
      c_bm_file_tmp_linelen type i value 80.
data: bm_file_tmp_lineofs   type i.
data: begin of bm_file_tmp occurs 0,
        l(80) type x,
      end of bm_file_tmp.
constants: c_bm_file8bit_linelen type i value 80.
data: bm_file8bit_lineofs   type i.
data: begin of bm_file8bit occurs 0,
        l(80) type x,
      end of bm_file8bit.
data: bitmap_file_lineofs   type i,
      bitmap_file_linewidth type i,
      bitmap_file_bytecount type i.
* BMP color table
DATA: BEGIN OF BMP_COLOR_TAB OCCURS 256,
  R TYPE x,
  G TYPE x,
  B TYPE x,
      END OF BMP_COLOR_TAB.
* TIFF: global format info
DATA: BEGIN OF TIF_INFO,
  BYTEORDER(1) TYPE C,
  VERSION TYPE I,
  FIRSTIFDOFS TYPE I,
  WIDTH TYPE I,
  LENGTH TYPE I,
  BITSPERSAMPLE_1 TYPE I,
  BITSPERSAMPLE_2 TYPE I,
  BITSPERSAMPLE_3 TYPE I,
  BITSPERSAMPLEPLANES TYPE I,
  COMPRESSION TYPE I,
  PHOTOMETRIC TYPE I,
  FILLORDER TYPE I,
  NUMBER_STRIPS TYPE I,
  SAMPLESPERPIX TYPE I,
  ROWSPERSTRIP TYPE I,
  MINSAMPLE TYPE I,
  MAXSAMPLE TYPE I,
  XRES_N TYPE I,
  XRES_D TYPE I,
  YRES_N TYPE I,
  YRES_D TYPE I,
  RESUNIT TYPE I,
  COLORMAP_SIZE TYPE I,
  MAXROW TYPE I,
  MAXCOL TYPE I,
  DPI TYPE I,
  TIFTYPE TYPE C,
  WIDTH_ORI TYPE I,
  LENGTH_ORI TYPE I,
  DPI_ORI TYPE I,
  END OF TIF_INFO.
* TIFF: list of strip offset pointers to image data
DATA: BEGIN OF TIF_STRIPOFS_TAB OCCURS 20,
  OFS TYPE I,
  COUNT TYPE I,
      END OF TIF_STRIPOFS_TAB.
* TIFF: list of color table entries
DATA: BEGIN OF TIF_COLOR_TAB OCCURS 256,
  R TYPE I,
  G TYPE I,
  B TYPE I,
      END OF TIF_COLOR_TAB.
* TIFF constants
CONSTANTS:
      C_BYTEORD_INTEL VALUE 'I',
      C_BYTEORD_MOTO  VALUE 'M',
      C_DTYPE_BYTE TYPE I VALUE 1,
      C_DTYPE_ASCII TYPE I VALUE 2,
      C_DTYPE_SHORT TYPE I VALUE 3,
      C_DTYPE_LONG TYPE I VALUE 4,
      C_DTYPE_RATIONAL TYPE I VALUE 5,
      C_TIFTYPE_NONE VALUE ' ',
      C_TIFTYPE_BILEVEL VALUE 'B',
      C_TIFTYPE_GRAYSCALE VALUE 'G',
      C_TIFTYPE_COLORMAP VALUE 'C',
      C_TIFTYPE_FULLCOLOR VALUE 'F',
      C_XCONST_80 TYPE X VALUE '80',
      C_XCONST_40 TYPE X VALUE '40',
      C_XCONST_20 TYPE X VALUE '20',
      C_XCONST_10 TYPE X VALUE '10',
      C_XCONST_08 TYPE X VALUE '08',
      C_XCONST_04 TYPE X VALUE '04',
      C_XCONST_02 TYPE X VALUE '02',
      C_XCONST_01 TYPE X VALUE '01',
      C_COMP_UNCOMP TYPE I VALUE 1,
      C_COMP_HUFFMAN TYPE I VALUE 2,
      C_COMP_PACKBITS TYPE I VALUE 32773.

*************************************************************
* BDS bitmap storage
*************************************************************
* BDS bitmaps: buffer that holds info on resident bitmaps
data  begin of bitmap_buffer_bds occurs 10.
        include structure stxbitmaps.
data:   act_w_tw like stxbitmaps-widthtw,
        act_h_tw like stxbitmaps-heighttw,
        act_dpi  like stxbitmaps-resolution.
data  end of bitmap_buffer_bds.
data: bdstab_lineofs   type i,
      bdstab_linewidth type i,
      bdstab_bytecount type i.

* BDS handling
constants:
  c_bds_classname type sbdst_classname value 'DEVC_STXD_BITMAP',
  c_bds_classtype type sbdst_classtype value 'OT',          " others
  c_bds_mimetype  type bds_mimetp      value 'application/octet-stream',
  c_bds_original  type sbdst_doc_var_tg value 'OR'.

* generating command lines
data:
  c_cmd_position_window like tline value '/:POSITION WINDOW',
  c_cmd_position_page   like tline value '/:POSITION PAGE',
  c_cmd_position_xy     like tline
                value '/:POSITION XORIGIN ''&1'' &2 YORIGIN ''&3'' &4',
  c_cmd_size_window     like tline value '/:SIZE WINDOW',
  c_cmd_size_page       like tline value '/:SIZE PAGE',
  c_cmd_size_dx         like tline value '/:SIZE WIDTH ''&1'' &2',
  c_cmd_size_dy         like tline value '/:SIZE HEIGHT ''&1'' &2',
  c_cmd_size_dxdy       like tline
                        value '/:SIZE WIDTH ''&1'' &2 HEIGHT ''&3'' &4',
  c_cmd_width           like tline value 'WIDTH ''&1'' &2',
  c_cmd_height          like tline value 'HEIGHT ''&1'' &2',
  c_cmd_box             like tline value '/:BOX',
  c_cmd_box_frame       like tline value 'FRAME ''&1'' &2',
  c_cmd_box_intensity   like tline value 'INTENSITY &1',
  c_cmd_box_x           like tline value 'XPOS ''&1'' &2',
  c_cmd_box_y           like tline value 'YPOS ''&1'' &2',
  c_cmd_box_xy          like tline
                        value 'XPOS ''&1'' &2 YPOS ''&3'' &4'.
data: l_commands like tline occurs 1 with header line.

* Globals for screen processing
*     Screen attributes
constants:
      c_screen_on   like screen-active value '1',
      c_screen_off  like screen-active value '0'.

data: fcode                     like sy-ucomm,
      fcode_old                 like sy-ucomm,
      f_found(1)                type c,
      f_action_canceled(1)      type c,
      f_resolution_changed(1)   type c,
      f_show_attributes_2001(1) type c,
      f_show_attributes_2002(1) type c,
      g_repid                   like sy-repid value 'SAPLSTXBITMAPS'.

constants:
      fcode_ok                like sy-ucomm value 'OK',
**    fcode_f3                like sy-ucomm value 'BACK',
      fcode_f12               like sy-ucomm value 'CANC',
**    fcode_f15               like sy-ucomm value 'BEEN',
      fcode_search            like sy-ucomm value 'CATA',
      fcode_import            like sy-ucomm value 'UPLD',
      fcode_detail            like sy-ucomm value 'DETAIL',
      fcode_btype             like sy-ucomm value 'BTYPE',
      fcode_gr_id             like sy-ucomm value 'GRAPHICS_ID',
      fcode_tab_bds           like sy-ucomm value 'STXBITMAPS',
      fcode_tab_grtext        like sy-ucomm value 'STXHGRAPHICS',
      fcode_tab_stdtext       like sy-ucomm value 'STXHTEXT'.

*     Tabstrips
controls:
      tabstrip_bitmaps   type tabstrip.
data: tabstrip_nr        like sy-dynnr.

define tab_bds.
  tabstrip_nr = '2001'.
  tabstrip_bitmaps-activetab = 'STXBITMAPS'.
end-of-definition.
define tab_stxh_graphics.
  tabstrip_nr = '2002'.
  tabstrip_bitmaps-activetab = 'STXHGRAPHICS'.
end-of-definition.


* Globals and globals for dynpro fields
data: g_objecttype(20)   type c,
      g_new_resolution   like stxbitmaps-resolution,
      g_stxbitmaps       type stxbitmaps,
      g_stxh             type stxh,
      g_techinfo         type rsscg,
      t_size(40),
      bds_description  like bapisignat-prop_value.
constants:
      c_objecttype_bds      like g_objecttype value 'BDS',
      c_objecttype_stdtext  like g_objecttype value 'OBTEXT',
      c_objecttype_grtext   like g_objecttype value 'OBGRAPHICS'.

* Graphic handling
constants:
      c_stdtext  like thead-tdobject value 'TEXT',
      c_graphics like thead-tdobject value 'GRAPHICS',
      c_bmon     like thead-tdid     value 'BMON',
      c_bcol     like thead-tdid     value 'BCOL'.
constants:
      c_screen_graphic_import       like sy-dynnr value '4000',
      c_screen_graphic_import_bds   like sy-dynnr value '4001'.
* radio buttons
data: rb_origin_page(1)      value ' ',
      rb_origin_window(1)    value 'X',
      rb_origin_absolute(1)  value ' ',
      rb_height_page(1)      value ' ',
      rb_height_window(1)    value ' ',
      rb_height_absolute(1)  value 'X',
      rb_width_page(1)       value ' ',
      rb_width_window(1)     value ' ',
      rb_width_absolute(1)   value 'X',
      rb_no_line(1)          value ' ',
      rb_line_user_def(1)    value 'X',
      rb_graphic_bmon(1)     value 'X',
      rb_graphic_bcol(1)     value ' ',
      rb_graphic_general(1)  value ' '.
* measures
data: box_left             like rstxu-negative,
      box_left_unit        like rstxu-unith,
      box_top              like rstxu-negative,
      box_top_unit         like rstxu-unitv,
      box_width            like rstxu-positive,
      box_width_unit       like rstxu-unith,
      box_height           like rstxu-positive,
      box_height_unit      like rstxu-unitv,
      box_origin_left      like rstxu-positive,
      box_origin_left_unit like rstxu-unith,
      box_origin_top       like rstxu-positive,
      box_origin_top_unit  like rstxu-unitv,
      box_frame            like rstxu-positive,
      box_frame_unit       like rstxu-unit.
