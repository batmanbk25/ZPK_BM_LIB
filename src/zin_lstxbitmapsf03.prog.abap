***INCLUDE LSTXUF03 .

constants: c_bitbuf_clear type c value 'C',
           c_bitbuf_push  type c value 'P',
           c_bitbuf_whitepix type x value '00',
           c_bitbuf_blackpix type x value '01'.
*******************************************************************
* ITF bitmap data encode/decode routines
*******************************************************************
form find_format tables lines structure tline
              using value(format)
                    value(startline)
                    formatline_index
                    textline.
  clear textline. formatline_index = 0.
  do.
    read table lines index startline.
    if sy-subrc <> 0.
      exit.
    endif.
    if lines-tdformat = format.
      textline = lines.
      formatline_index = startline.
      exit.
    endif.
    add 1 to startline.
  enddo.
endform.

*---------------------------------------------------------------------*
form find_cmd tables lines structure tline
              using value(cmd)
                    value(startline)
                    cmdline_index
                    textline.
  clear textline. cmdline_index = 0.
  do.
    read table lines index startline.
    if sy-subrc <> 0.
      exit.
    endif.
    if lines-tdformat = c_itf_format_cmd.
      if lines-tdline cs cmd.
        if sy-fdpos = 0.
          textline = lines.
          cmdline_index = startline.
          exit.
        endif.
      endif.
    endif.
    add 1 to startline.
  enddo.
endform.

*---------------------------------------------------------------------*
form find_cmnt tables lines structure tline
              using value(comment)
                    value(startline)
                    commentline_index
                    textline.
  clear textline. commentline_index = 0.
  do.
    read table lines index startline.
    if sy-subrc <> 0.
      exit.
    endif.
    if lines-tdformat = c_itf_format_cmnt.
      if lines-tdline cs comment.
        if sy-fdpos = 0.
          textline = lines.
          commentline_index = startline.
          exit.
        endif.
      endif.
    endif.
    add 1 to startline.
  enddo.
endform.

*---------------------------------------------------------------------*
form hex_2_int using value(hexbyte) val.
  statics: x type x,
           c2(2) type c.
  c2 = hexbyte.
  x = c2.
  val = x.
endform.

********************************************************
* LT_... funcs to read/fill LINES ITF table
********************************************************
form lt_get_byte tables lines structure tline
                 using cur_line
                       cur_lineofs
                       byteval type x.
  statics: c2(2) type c.

  read table lines index cur_line.
  check sy-subrc = 0.
  if cur_lineofs > 132. sy-subrc = 1. exit. endif.
  c2 = lines-tdline+cur_lineofs(2).
  perform hex_2_int using c2 byteval.
  add 2 to cur_lineofs.
  if cur_lineofs = 132.
    cur_lineofs = 0.
    add 1 to cur_line.
  endif.
endform.

*---------------------------------------------------------------------*
form lt_put_byte tables lines structure tline
                 using cur_lineofs
                       byteval type x.
  statics: c2(2) type c.

  c2 = byteval.
  lines-tdline+cur_lineofs(2) = c2.
  add 2 to cur_lineofs.
  if cur_lineofs = 132.
    cur_lineofs = 0.
    append lines. clear lines-tdline.
  endif.
endform.

*---------------------------------------------------------------------*
form lt_put_2byte_int tables lines structure tline
                 using cur_lineofs
                       int type i.
  statics: lo type x,
           hi type x.

  hi = int div 256.
  lo = int mod 256.
  perform lt_put_byte tables lines
                      using cur_lineofs hi.
  perform lt_put_byte tables lines
                      using cur_lineofs lo.
endform.

*---------------------------------------------------------------------*
form lt_put_4byte_int tables lines structure tline
                 using cur_lineofs
                       int type i.
  statics: lo type i,
           hi type i.

  hi = int div 65536.
  lo = int mod 65536.
  perform lt_put_2byte_int tables lines
                           using cur_lineofs hi.
  perform lt_put_2byte_int tables lines
                           using cur_lineofs lo.
endform.

*---------------------------------------------------------------------*
form lt_flush tables lines structure tline
              using cur_lineofs.
  if cur_lineofs > 0.
    append lines.
  endif.
endform.

********************************************************
* ..._BYTE funcs to read/fill LINES ITF line
********************************************************
form get_byte using value(line) like tline-tdline
                    ofs
                    byteval type x.
  data: c2(2) type c.

  c2 = line+ofs(2).
  add 2 to ofs.
  perform hex_2_int using c2 byteval.
endform.

*---------------------------------------------------------------------*
form set_byte using line like tline-tdline
                    ofs
                    value(byteval) type x.
  data: c2(2) type c.

  write byteval to c2.
  line+ofs(2) = c2.
  add 2 to ofs.
endform.

*---------------------------------------------------------------------*
form get_2byte_int using value(line) like tline-tdline
                         ofs
                         intval.
  statics: i type x.

  perform get_byte using line ofs i.
  intval = i * 256.
  perform get_byte using line ofs i.
  intval = intval + i.
endform.

*---------------------------------------------------------------------*
form set_2byte_int using line like tline-tdline
                         ofs
                         value(intval).
  statics: x type x.

  x = intval div 256.
  perform set_byte using line ofs x.
  x = intval mod 256.
  perform set_byte using line ofs x.
endform.

*---------------------------------------------------------------------*
form get_4byte_int using value(line) like tline-tdline
                         ofs
                         intval.
  statics: i type i.

  perform get_2byte_int using line ofs i.
  intval = i * 256 * 256.
  perform get_2byte_int using line ofs i.
  intval = intval + i.
endform.

*---------------------------------------------------------------------*
form set_4byte_int using line like tline-tdline
                         ofs
                         value(intval).
  statics: i type i.

  i = intval div ( 256 * 256 ).
  perform set_2byte_int using line ofs i.
  i = intval mod ( 256 * 256 ).
  perform set_2byte_int using line ofs i.
endform.

********************************************************
* ITF format decode funcs
********************************************************
form get_itf_token using value(line) like tline-tdline
                         ofs
                         tokenval.
  constants: tline_maxofs type i value 132.
  data: startofs type i,
        len type i,
        c.
  field-symbols: <p>.

  clear tokenval.
  c = line+ofs(1).
  while c = space.
    add 1 to ofs.
    if ofs = tline_maxofs. exit. endif.
    c = line+ofs(1).
  endwhile.
  check ofs < tline_maxofs.
  startofs = ofs.
  while c <> space.
    add 1 to ofs.
    if ofs = tline_maxofs. exit. endif.
    c = line+ofs(1).
  endwhile.
  check ofs < tline_maxofs.
  len = ofs - startofs.
  if len > 0.
    assign line+startofs(len) to <p>.
    tokenval = <p>.
  endif.
endform.

*---------------------------------------------------------------------*
form cnv_itf_token_to_num using value(token) type c
                                number.
  statics: t(40) type c,
           c type c.

  number = 0.
  t = token.
  c = t.
  while '0123456789 .' ca c.
    if ( sy-fdpos >= 0 ) and ( sy-fdpos <= 9 ).
      number = 10 * number + sy-fdpos.
    else.
      exit.
    endif.
    shift t. c = t.
  endwhile.
endform.

*---------------------------------------------------------------------*
form get_itf_height_tw using value(line) like tline-tdline
                             height type i.
  statics: ofs type i,
           token(40) type c.

  height = 0.
  check line cs c_itf_hex_height.
  ofs = sy-fdpos + strlen( c_itf_hex_height ).
  perform get_itf_token using line
                              ofs
                              token.
  check token <> space.
  perform cnv_itf_token_to_num using token
                                     height.
  perform get_itf_token using line
                              ofs
                              token.
  check token <> space.
  case token.
    when c_itf_hex_cm.    height = ( 144000 * height ) / 254.
    when c_itf_hex_mm.    height = ( 14400 * height ) / 254.
    when c_itf_hex_point. height = 20 * height.
    when c_itf_hex_twip.
    when others.          height = 0.
  endcase.
endform.

*---------------------------------------------------------------------*
form set_itf_height_tw using line like tline-tdline
                             value(height_tw) type i.
  statics: ofs type i,
           tok_height(10) type c,
           tok_unit(10) type c,
           h_n6(6) type n.

  h_n6 = height_tw.
  if line ns c_itf_hex_height.
    sy-subrc = 1. exit.
  endif.
  ofs = sy-fdpos + strlen( c_itf_hex_height ).
  perform get_itf_token using line
                              ofs
                              tok_height.
  if tok_height = space.
    sy-subrc = 1. exit.
  endif.
  perform get_itf_token using line
                              ofs
                              tok_unit.
  if tok_unit = space.
    sy-subrc = 1. exit.
  endif.
  case tok_unit.
    when c_itf_hex_cm.
    when c_itf_hex_mm.
    when c_itf_hex_point.
    when c_itf_hex_twip.
    when others.          sy-subrc = 1. exit.
  endcase.
  perform replace_itf_token using line
                                  tok_height
                                  h_n6.
  check sy-subrc = 0.
  perform replace_itf_token using line
                                  tok_unit
                                  c_itf_hex_twip.
endform.

*---------------------------------------------------------------------*
form replace_itf_token using line like tline-tdline
                             value(token)
                             value(replacement).
  statics len like sy-fdpos.

  len = strlen( token ).
  replace token with replacement into line length len.
  condense line.
endform.

* fill structure OTF_BMINFO with bitmap attributes
* returns CUR_LINE, CUR_LINEOFS which point to start of
* colormap+bitmap data
form get_bitmap_attributes tables lines structure tline
                           using cur_line
                                 cur_lineofs type i.
  data: pos_hex like sy-tabix,
        pos_endhex like sy-tabix,
        pos_data like sy-tabix,
        tline like tline,
        byte type x,
        formatid type x,
        subformatid type x,
        formatpar1 type x,
        formatpar2 type x,
        byte_hi type x,
        byte_lo type x.

  cur_line = 1.
* find /: HEX...
  perform find_cmd tables lines
                   using c_itf_hex_hex
                         cur_line
                         pos_hex
                         tline.
* check /:  HEX...
  if pos_hex = 0.
    message e877 raising no_bitmap_file.
  endif.
  if tline-tdline ns c_itf_hex_type.
    message e877 raising no_bitmap_file.
  endif.
  if tline-tdline cs c_itf_hex_bmon.
    otf_bminfo-bmtype = c_itf_hex_bmon.
    otf_bminfo-is_monochrome = c_true.
  elseif tline-tdline cs c_itf_hex_bcol.
    otf_bminfo-bmtype = c_itf_hex_bcol.
    otf_bminfo-is_monochrome = c_false.
  else.
    message e877 raising no_bitmap_file.
  endif.
  if tline-tdline cs c_itf_hex_resi.
    otf_bminfo-new_rd_format = c_true.
  else.
    otf_bminfo-new_rd_format = c_false.
  endif.
  otf_bminfo-is_resident = c_false.
* get /: HEX ... HEIGHT xxxxx UU value
  perform get_itf_height_tw using tline-tdline
                                  otf_bminfo-res_h_tw.
* find /: ENDHEX...
  cur_line = pos_hex.
  perform find_cmd tables lines
                   using c_itf_hex_endhex
                         cur_line
                         pos_endhex
                         tline.
  if pos_endhex = 0 or pos_endhex < pos_hex.
    message e877 raising no_bitmap_file.
  endif.
* find 1st data line
  perform find_format tables lines
                      using '/='
                            pos_hex
                            pos_data
                            tline.
  if pos_data = 0 or pos_data > pos_endhex.
    message e877 raising no_bitmap_file.
  endif.
  cur_line = pos_data.
* parse 1st data line:
*  8 magic leader bytes
  if tline-tdline(16) <> c_otf_rd_otfbitma.
    message e877 raising no_bitmap_file.
  endif.
  cur_lineofs = 2 * 8.
  if otf_bminfo-new_rd_format = c_true.
*  new format: FFFF + 4 data format bytes
    do 4 times.
      perform get_byte using tline-tdline
                             cur_lineofs
                             byte.
      if byte <> c_otf_rd_ff.
        message e873 with byte raising bad_bitmap_type.
      endif.
    enddo.
    perform get_byte using tline-tdline
                           cur_lineofs
                           formatid.
    perform get_byte using tline-tdline
                           cur_lineofs
                           subformatid.
    perform get_byte using tline-tdline
                           cur_lineofs
                           formatpar1.
    perform get_byte using tline-tdline
                           cur_lineofs
                           formatpar2.
    case formatid.
      when c_otf_rd_formatid_bmon.
        otf_bminfo-is_monochrome = c_true.
      when c_otf_rd_formatid_bcol.
        otf_bminfo-is_monochrome = c_false.
      when others.
        message e873 with formatid raising bad_bitmap_type.
    endcase.
    byte_lo = formatpar1 mod 16.
    byte_hi = ( formatpar1 div 16 ) * 16.
    case byte_lo.
      when c_otf_rd_formatpar1_nonresi.
        otf_bminfo-is_resident = c_false.
      when c_otf_rd_formatpar1_resi.
        otf_bminfo-is_resident = c_true.
      when others.
        message e873 with formatpar1 raising bad_bitmap_type.
    endcase.
    case byte_hi.
      when c_otf_rd_formatpar1_hi_nocomp.
        otf_bminfo-is_compressed = c_false.
      when c_otf_rd_formatpar1_hi_runl.
        otf_bminfo-is_compressed = c_true.
      when others.
        message e873 with formatpar1 raising bad_bitmap_type.
    endcase.
  endif.
* width height etc.
  perform get_4byte_int using tline-tdline
                              cur_lineofs
                              otf_bminfo-w_tw.
  perform get_4byte_int using tline-tdline
                              cur_lineofs
                              otf_bminfo-h_tw.
  perform get_4byte_int using tline-tdline
                              cur_lineofs
                              otf_bminfo-w_pix.
  perform get_4byte_int using tline-tdline
                              cur_lineofs
                              otf_bminfo-h_pix.
  perform get_2byte_int using tline-tdline
                              cur_lineofs
                              otf_bminfo-dpi.
  perform get_2byte_int using tline-tdline
                              cur_lineofs
                              otf_bminfo-bitsperpix.
  perform get_2byte_int using tline-tdline
                              cur_lineofs
                              otf_bminfo-coltabsize.
  perform get_4byte_int using tline-tdline
                              cur_lineofs
                              otf_bminfo-numdatabytes.
  if otf_bminfo-new_rd_format = c_true.
    cur_lineofs = cur_lineofs + 2 * c_otf_rd_imageid_len.
    while cur_lineofs >= c_itf_tline_len.
      cur_lineofs = cur_lineofs - c_itf_tline_len.
      add 1 to cur_line.
    endwhile.
  endif.
  if otf_bminfo-res_h_tw = otf_bminfo-h_tw.
    otf_bminfo-autoheight = c_true.
  else.
    otf_bminfo-autoheight = c_false.
  endif.
endform.

* modify bitmap attr. from structure OTF_BMINFO
form set_bitmap_attributes tables lines structure tline.

  data: cur_line like sy-tabix,
        pos_hex like sy-tabix,
        pos_endhex like sy-tabix,
        pos_data like sy-tabix,
        pos_comment like sy-tabix,
        tline like tline,
        byte type x,
        formatid type x,
        subformatid type x,
        formatpar1 type x,
        formatpar2 type x,
        ofs type i.

  cur_line = 1.
* find /: HEX...
  perform find_cmd tables lines
                   using c_itf_hex_hex
                         cur_line
                         pos_hex
                         tline.
* check /:  HEX...
  if pos_hex = 0.
    message e877 raising no_bitmap_file.
  endif.
  if tline-tdline ns c_itf_hex_type.
    message e877 raising no_bitmap_file.
  endif.
  if tline-tdline cs c_itf_hex_bmon.
    otf_bminfo-bmtype = c_itf_hex_bmon.
    otf_bminfo-is_monochrome = c_true.
  elseif tline-tdline cs c_itf_hex_bcol.
    otf_bminfo-bmtype = c_itf_hex_bcol.
    otf_bminfo-is_monochrome = c_false.
  else.
    message e877 raising no_bitmap_file.
  endif.
  if tline-tdline cs c_itf_hex_resi.
    otf_bminfo-new_rd_format = c_true.
  else.
    otf_bminfo-new_rd_format = c_false.
  endif.
  if otf_bminfo-new_rd_format = c_false.
    message e873 with space raising bad_bitmap_type.
*** raise bad_bitmap_type. "cannot change attributes of old files
  endif.
* find /: ENDHEX...
  cur_line = pos_hex.
  perform find_cmd tables lines
                   using c_itf_hex_endhex
                         cur_line
                         pos_endhex
                         tline.
  if pos_endhex = 0 or pos_endhex < pos_hex.
    message e877 raising no_bitmap_file.
  endif.
* find "TIFF baseline 6.0" comment line
  perform find_cmnt tables lines
                using 'TIFF baseline 6.0 file converted to' "#EC NOTEXT
                      pos_hex
                      pos_comment
                      tline.
  if pos_comment > pos_endhex.
    pos_comment = 0.
  endif.
* find 1st data line
  perform find_format tables lines
                      using c_itf_format_datl
                            pos_hex
                            pos_data
                            tline.
  if pos_data = 0 or pos_data > pos_endhex.
    message e877 raising no_bitmap_file.
  endif.
* parse 1st data line:
*  8 magic leader bytes
  if tline-tdline(16) <> c_otf_rd_otfbitma.
    message e877 raising no_bitmap_file.
  endif.
  ofs = 2 * 8.
*  new format: FFFF + 4 data format bytes
  do 4 times.
    perform get_byte using tline-tdline
                           ofs
                           byte.
    if byte <> c_otf_rd_ff.
      message e873 with byte raising bad_bitmap_type.
    endif.
  enddo.
  perform get_byte using tline-tdline
                         ofs
                         formatid.
  case formatid.
    when c_otf_rd_formatid_bmon.
      otf_bminfo-is_monochrome = c_true.
    when c_otf_rd_formatid_bcol.
      otf_bminfo-is_monochrome = c_false.
    when others.
      message e873 with formatid raising bad_bitmap_type.
  endcase.
  perform get_byte using tline-tdline
                         ofs
                         subformatid.
  if otf_bminfo-is_resident = c_true.
    formatpar1 = c_otf_rd_formatpar1_resi.
  else.
    formatpar1 = c_otf_rd_formatpar1_nonresi.
  endif.
  perform set_byte using tline-tdline  "set resident attribute
                         ofs
                         formatpar1.
  perform get_byte using tline-tdline
                         ofs
                         formatpar2.
* width height etc.
  data: ofs_hw_tw type i.
  ofs_hw_tw = ofs.
  perform get_4byte_int using tline-tdline
                              ofs
                              otf_bminfo-w_tw.
  perform get_4byte_int using tline-tdline
                              ofs
                              otf_bminfo-h_tw.
  perform get_4byte_int using tline-tdline
                              ofs
                              otf_bminfo-w_pix.
  perform get_4byte_int using tline-tdline
                              ofs
                              otf_bminfo-h_pix.
  perform set_2byte_int using tline-tdline          "set dpi attribute
                              ofs
                              otf_bminfo-dpi.
* re-calculate w/h in twip
  otf_bminfo-w_tw = ( 1440 *  otf_bminfo-w_pix ) / otf_bminfo-dpi.
  otf_bminfo-h_tw = ( 1440 *  otf_bminfo-h_pix ) / otf_bminfo-dpi.
  perform set_4byte_int using tline-tdline
                              ofs_hw_tw
                              otf_bminfo-w_tw.
  perform set_4byte_int using tline-tdline
                              ofs_hw_tw
                              otf_bminfo-h_tw.
  modify lines from tline index pos_data.
* find "TIFF baseline 6.0" comment line
  data: dpi(3) type n.
  perform find_cmnt tables lines
                using 'TIFF baseline 6.0 file converted to' "#EC NOTEXT
                      pos_hex
                      pos_comment
                      tline.
  if pos_comment > 0.
    tline-tdline =
  'TIFF baseline 6.0 file converted to $ resolution $'. "#EC NOTEXT
    replace '$' into tline-tdline with otf_bminfo-bmtype.
    dpi = otf_bminfo-dpi.
    replace '$' into tline-tdline with dpi.
    condense tline-tdline.
    modify lines from tline index pos_comment.
  endif.
* set "/: HEX ... HEIGHT xxxx ..."
  if otf_bminfo-autoheight = c_true.
    otf_bminfo-res_h_tw = otf_bminfo-h_tw.
  else.
    otf_bminfo-res_h_tw = 0.
  endif.
  read table lines index pos_hex.
  tline = lines.
  perform set_itf_height_tw using tline-tdline
                                  otf_bminfo-res_h_tw.
  if sy-subrc <> 0.
    message e873 with space raising bad_bitmap_type.
  else.
    modify lines from tline index pos_hex.
  endif.
endform.

*******************************************************************
* maintaining BM_FILE table (bitmap file buffer)
*******************************************************************
form bm_file_init.
  refresh bm_file.
  clear bm_file.
  bm_file_lineofs = 0.
endform.

*---------------------------------------------------------------------*
form bm_file_putbyte using value(byte) type x.
  bm_file-l+bm_file_lineofs(1) = byte.
  add 1 to bm_file_lineofs.
  if bm_file_lineofs =  c_bm_file_linelen.
    append bm_file.
    clear bm_file.
    bm_file_lineofs = 0.
  endif.
endform.

*---------------------------------------------------------------------*
form bm_file_flush.
  if bm_file_lineofs > 0.
    append bm_file.
  endif.
endform.

*---------------------------------------------------------------------*

form bm_file_getbyte using value(ofs) type i
                           byte type x.
  statics: tabix like sy-tabix,
           lofs type i.

  tabix = ofs div c_bm_file_linelen.
  add 1 to tabix.
  read table bm_file index tabix.
  if sy-subrc <> 0.
    byte = 0. exit.
  else.
    lofs = ofs mod c_bm_file_linelen.
    byte = bm_file-l+lofs(1).
  endif.
endform.

*---------------------------------------------------------------------*
form bm_file_getword using value(ofs) type i
                           word type i.
  statics: byte type x.

  perform bm_file_getbyte using ofs byte.
  word = byte * 256.
  add 1 to ofs.
  perform bm_file_getbyte using ofs byte.
  word = word + byte.
endform.

*******************************************************************
* maintaining BM_FILE_TMP table (bitmap file buffer)
*******************************************************************
form bm_file_tmp_init.
  refresh bm_file_tmp.
  clear bm_file_tmp.
  bm_file_tmp_lineofs = 0.
endform.

*---------------------------------------------------------------------*
form bm_file_tmp_putbyte using value(byte) type x.
  bm_file_tmp-l+bm_file_tmp_lineofs(1) = byte.
  add 1 to bm_file_tmp_lineofs.
  if bm_file_tmp_lineofs =  c_bm_file_tmp_linelen.
    append bm_file_tmp.
    clear bm_file_tmp.
    bm_file_tmp_lineofs = 0.
  endif.
endform.

*---------------------------------------------------------------------*
form bm_file_tmp_putnibble using value(nibble) type x
                                 firstnibble type c.
  statics byte type x.

  if firstnibble = 'X'.
    nibble = nibble * 16.
    bm_file_tmp-l+bm_file_tmp_lineofs(1) = nibble.
    firstnibble = space.
  else.
    byte = bm_file_tmp-l+bm_file_tmp_lineofs(1).
    byte = byte + nibble.
    bm_file_tmp-l+bm_file_tmp_lineofs(1) = byte.
    add 1 to bm_file_tmp_lineofs.
    if bm_file_tmp_lineofs =  c_bm_file_tmp_linelen.
      append bm_file_tmp.
      clear bm_file_tmp.
      bm_file_tmp_lineofs = 0.
    endif.
    firstnibble = 'X'.
  endif.
endform.

*---------------------------------------------------------------------*
form bm_file_tmp_flush using firstnibble type c.
  if bm_file_tmp_lineofs = 0.
    if firstnibble = space.
      append bm_file_tmp.
    endif.
  else.
    append bm_file_tmp.
  endif.
endform.

*---------------------------------------------------------------------*
form bm_file_tmp_getbyte using value(ofs) type i
                               byte type x.
  statics: tabix like sy-tabix,
           lofs type i.

  tabix = ofs div c_bm_file_tmp_linelen.
  add 1 to tabix.
  read table bm_file_tmp index tabix.
  if sy-subrc <> 0.
    byte = 0. exit.
  else.
    lofs = ofs mod c_bm_file_tmp_linelen.
    byte = bm_file_tmp-l+lofs(1).
  endif.
endform.

*******************************************************************
* maintaining BM_FILE8BIT table (8bit bitmap file buffer)
*******************************************************************
form bm_file8bit_init.
refresh bm_file8bit.
clear bm_file8bit.
bm_file8bit_lineofs = 0.
endform.

form bm_file8bit_putbyte using value(byte) type x.
bm_file8bit-l+bm_file8bit_lineofs(1) = byte.
add 1 to bm_file8bit_lineofs.
if bm_file8bit_lineofs = c_bm_file8bit_linelen.
  append bm_file8bit.
  clear bm_file8bit.
  bm_file8bit_lineofs = 0.
endif.
endform.

form bm_file8bit_flush.
if bm_file8bit_lineofs > 0.
  append bm_file8bit.
endif.
endform.

form bm_file8bit_getbyte using value(ofs) type i
                               byte type x.
statics: tabix like sy-tabix,
         lofs type i.

tabix = ofs div c_bm_file8bit_linelen.
add 1 to tabix.
read table bm_file8bit index tabix.
if sy-subrc <> 0.
  byte = 0. exit.
else.
  lofs = ofs mod c_bm_file8bit_linelen.
  byte = bm_file8bit-l+lofs(1).
endif.
endform.

*******************************************************************
* ITF to BMP conversion, step 1
*******************************************************************
form fill_bmfile_from_itf tables itflines structure tline.
  data: cur_line like sy-tabix,
        cur_lineofs type i,
        byte type x.

  perform get_bitmap_attributes tables itflines
                                using cur_line
                                      cur_lineofs.
  perform bm_file_init.
  if otf_bminfo-is_monochrome = c_false.
    do otf_bminfo-coltabsize times.
      do 6 times.                      "3 RGB 2-byte integers
        perform lt_get_byte tables itflines
                         using cur_line
                               cur_lineofs
                               byte.
        perform bm_file_putbyte using byte.
      enddo.
    enddo.
  endif.
  do otf_bminfo-numdatabytes times.
    perform lt_get_byte tables itflines
                     using cur_line
                           cur_lineofs
                           byte.
    if sy-subrc <> 0.
      message e877 raising no_bitmap_file.
    endif.
    perform bm_file_putbyte using byte.
  enddo.
  perform bm_file_flush.
endform.

*******************************************************************
* BDS to BMP conversion, step 1
*******************************************************************
form fill_bmfile_from_bds tables bdstab type sbdst_content.
data: ofs type i,
      byte type x,
      expected_filesize type i,
      runcount type i,
      decomp_filesize type i,
      decomp_linesize type i,
      bytes_per_row type i,
      bytes_per_row_act type i,
      mod type i.

perform bdstab_init_readonly tables bdstab.
* check bitmap header
perform bdstab_get_imageheader tables bdstab
                               using ofs
                                     c_false
                                     0
                                     c_false
                                     space
                                     expected_filesize
                                     bytes_per_row
                                     bytes_per_row_act.
if sy-subrc <> 0.
  raise bdserr_invalid_format.
endif.
perform bm_file_init.
if otf_bminfo-is_monochrome = c_false.
  do otf_bminfo-coltabsize times.
    do 6 times.                      "3 RGB 2-byte integers
      perform bdstab_getbyte tables bdstab
                             using ofs
                                   byte.
      perform bm_file_putbyte using byte.
    enddo.
  enddo.
endif.
if otf_bminfo-is_compressed = 'X'.
* decompress run-length compressed bitmap
  decomp_filesize = decomp_linesize = 0.
  do.
    perform bdstab_getbyte tables bdstab using ofs byte.
    if sy-subrc <> 0.
      raise bdserr_eof.
    endif.
    if byte < 128.
      runcount = byte + 1.
      do runcount times.
        perform bdstab_getbyte tables bdstab using ofs byte.
        perform bm_file_putbyte using byte.
        add 1 to decomp_linesize.
      enddo.
    elseif byte > 128.
      runcount = 257 - byte.
      perform bdstab_getbyte tables bdstab using ofs byte.
      do runcount times.
        perform bm_file_putbyte using byte.
        add 1 to decomp_linesize.
      enddo.
    else.
      exit.
    endif.
    if decomp_linesize = bytes_per_row_act.
      runcount = bytes_per_row - bytes_per_row_act.
      byte = '00'.
      do runcount times.
        perform bm_file_putbyte using byte.
        add 1 to decomp_linesize.
      enddo.
      add decomp_linesize to decomp_filesize.
      decomp_linesize = 0.
    endif.
  enddo.
  otf_bminfo-numdatabytes = decomp_filesize.
else.
* no decompression
  do otf_bminfo-numdatabytes times.
    perform bdstab_getbyte tables bdstab using ofs byte.
    if sy-subrc <> 0.
      raise bdserr_eof.
    endif.
    perform bm_file_putbyte using byte.
  enddo.
endif.
perform bm_file_flush.
endform.

*******************************************************************
* maintaining BMPTAB (function tables param) binary file table
*******************************************************************
form bmptab_init tables bmptab.
  data: bmptab_linetype(1).

  refresh bmptab. clear bmptab.
  bitmap_file_lineofs = 0.
  bitmap_file_bytecount = 0.
  describe field bmptab type bmptab_linetype.
  if bmptab_linetype <> 'X'.
*   message E879 with bmptab_linetype RAISing BITMAP_FILE_NOT_TYPE_X.
  endif.
  describe field bmptab length bitmap_file_linewidth
                               in byte mode.
endform.

*---------------------------------------------------------------------*
form bmptab_init_readonly tables bmptab.
  data: bmptab_linetype(1).
  clear tif_info-byteorder.
  bitmap_file_lineofs = 0.
  bitmap_file_bytecount = 0.
  describe field bmptab type bmptab_linetype.
  if bmptab_linetype <> 'X'.
*   message E879 with bmptab_linetype RAISing BITMAP_FILE_NOT_TYPE_X.
  endif.
  describe field bmptab length bitmap_file_linewidth
                               in byte mode.
endform.

*---------------------------------------------------------------------*
form bmptab_setbyte_ofs tables bmptab
                        using ofs type i
                              byte type x.
statics: tabix like sy-tabix.
field-symbols <p>.

tabix = ofs div bitmap_file_linewidth.
add 1 to tabix.
bitmap_file_lineofs = ofs mod bitmap_file_linewidth.
read table bmptab index tabix.
if sy-subrc <> 0.
  message e878 raising bmperr_eof.
endif.
*  assign bmptab+bitmap_file_lineofs(1) to <p> type 'X'.
assign bmptab to <p> type 'X'.
<p>+bitmap_file_lineofs(1) = byte.
modify bmptab index tabix.
add 1 to ofs.
endform.

*---------------------------------------------------------------------*
form bmptab_getbyte_ofs tables bmptab
                        using ofs type i
                              byte type x.
statics: tabix like sy-tabix.
field-symbols <p>.

tabix = ofs div bitmap_file_linewidth.
add 1 to tabix.
bitmap_file_lineofs = ofs mod bitmap_file_linewidth.
read table bmptab index tabix.
if sy-subrc <> 0.
  message e878 raising bmperr_eof.
endif.
*assign bmptab+bitmap_file_lineofs(1) to <p> type 'X'.
assign bmptab to <p> type 'X'.
byte = <p>+bitmap_file_lineofs(1).
add 1 to ofs.
endform.

*---------------------------------------------------------------------*
form bmptab_setword_ofs tables bmptab
                        using ofs type i
                              word type i.
  statics: byte type x.

  byte = word mod 256.
  perform bmptab_setbyte_ofs tables bmptab
                             using ofs
                                   byte.
  byte = word div 256.
  perform bmptab_setbyte_ofs tables bmptab
                             using ofs
                                   byte.
endform.

*---------------------------------------------------------------------*
form bmptab_getword_ofs tables bmptab
                        using ofs type i
                              word type i.
  statics: byte type x.

  perform bmptab_getbyte_ofs tables bmptab
                             using ofs
                                   byte.
  word = byte.
  perform bmptab_getbyte_ofs tables bmptab
                             using ofs
                                   byte.
  if tif_info-byteorder = c_byteord_moto.
    word = 256 * word + byte.
  else.
    word = word + 256 * byte.
  endif.
endform.

*---------------------------------------------------------------------*
form bmptab_setdword_ofs tables bmptab
                         using ofs type i
                               dword type i.
  constants x10000 type i value 65536.
  statics: word type i.

  word = dword mod x10000.
  perform bmptab_setword_ofs tables bmptab
                             using ofs
                                   word.
  word = dword div x10000.
  perform bmptab_setword_ofs tables bmptab
                             using ofs
                                   word.
endform.

*---------------------------------------------------------------------*
form bmptab_getdword_ofs tables bmptab
                         using ofs type i
                               dword type i.
  constants x10000 type i value 65536.
  statics: word type i.

  perform bmptab_getword_ofs tables bmptab
                             using ofs
                                   word.
  dword = word.
  perform bmptab_getword_ofs tables bmptab
                             using ofs
                                   word.
  if tif_info-byteorder = c_byteord_moto.
    if dword < 32768. "prevent integer overflow
      dword = X10000 * dword + word.
    else.
      dword = -1.
    endif.
  else.
    if word < 32768. "prevent integer overflow
      dword = dword + x10000 * word.
    else.
      dword = -1.
    endif.
  endif.
endform.

*---------------------------------------------------------------------*
form bmptab_getlong_ofs tables bmptab
                        using ofs type i
                              long type i.
  constants: x10000 type i value 65536,
             x08000 type i value 32768,
             x0ffff type i value 65535.
  statics: word_lo type i,
           word_hi type i.
  perform bmptab_getword_ofs tables bmptab
                             using ofs
                                   word_lo.
  perform bmptab_getword_ofs tables bmptab
                             using ofs
                                   word_hi.
  if word_hi >= x08000.
    if word_hi = x0ffff.
      long = word_lo - x10000.
    else.
    endif.
  else.
    long = word_lo + x10000 * word_hi.
  endif.
endform.

*---------------------------------------------------------------------*
form bmptab_putbyte tables bmptab
                    using byte type x.
field-symbols <p>.

*  assign bmptab+bitmap_file_lineofs(1) to <p> type 'X'.
assign bmptab to <p> type 'X'.
<p>+bitmap_file_lineofs(1) = byte.
add 1 to bitmap_file_lineofs.
if bitmap_file_lineofs = bitmap_file_linewidth.
  append bmptab.
  bitmap_file_lineofs = 0.
endif.
add 1 to bitmap_file_bytecount.
endform.

* write BMP file WORD (16 bit unsigned int) intel byte order: LO,HI
form bmptab_putword tables bmptab
                    using word type i.
  statics: x type x.

  x = word mod 256.
  perform bmptab_putbyte tables bmptab
                         using x.
  x = word div 256.
  perform bmptab_putbyte tables bmptab
                         using x.
endform.

* write BMP file DWORD (32 bit unsigned int) intel byte order: LO,HI
form bmptab_putdword tables bmptab
                     using dword type i.
  statics: word type i.
  constants x10000 type i value 65536.

  word = dword mod x10000.
  perform bmptab_putword tables bmptab
                         using word.
  word = dword div x10000.
  perform bmptab_putword tables bmptab
                         using word.
endform.

* write BMP file LONG (32 bit signed int) intel byte order: LO,HI
form bmptab_putlong tables bmptab
                    using long type i.
  statics: word_lo type i,
           word_hi type i.
  constants: x10000 type i value 65536,
             x1000000 type i value 16777216.

  if long >= 0.
    word_lo = long mod x10000.
    word_hi = long div x10000.
  else.
    long = abs( long ).
    if long < x10000.
      word_hi = x10000 - 1.            "$ffff
      word_lo = x10000 - long.
    else.
*
    endif.
  endif.
  perform bmptab_putword tables bmptab
                         using word_lo.
  perform bmptab_putword tables bmptab
                         using word_hi.
endform.

*---------------------------------------------------------------------*
form bmptab_flush tables bmptab.
  if bitmap_file_lineofs > 0.
    append bmptab.
  endif.
endform.

*******************************************************************
* maintaining BDSTAB (function tables param) binary file table
*******************************************************************
form bdstab_init tables bdstab type sbdst_content.
data: bdstab_linetype(1).

refresh bdstab. clear bdstab.
bdstab_lineofs = 0.
bdstab_bytecount = 0.
describe field bdstab type bdstab_linetype.
if bdstab_linetype <> 'X'.
* message E879 with bmptab_linetype RAISing BITMAP_FILE_NOT_TYPE_X.
endif.
describe field bdstab length bdstab_linewidth
                      in byte mode.
endform.

form bdstab_init_readonly tables bdstab type sbdst_content.
bdstab_lineofs = 0.
bdstab_bytecount = 0.
describe field bdstab length bdstab_linewidth
                      in byte mode.
endform.

* write BYTE to BDSTAB
form bdstab_putbyte tables bdstab type sbdst_content
                    using byte type x.
field-symbols <p>.

*assign bdstab+bdstab_lineofs(1) to <p> type 'X'.
assign bdstab to <p> type 'X'.
assign <p>+bdstab_lineofs(1) to <p>.
<p> = byte.
add 1 to bdstab_lineofs.
if bdstab_lineofs = bdstab_linewidth.
  append bdstab.
  bdstab_lineofs = 0.
endif.
add 1 to bdstab_bytecount.
endform.

* write BYTE to already filled BDSTAB
form bdstab_setbyte tables bdstab type sbdst_content
                    using ofs type i
                          byte type x.
field-symbols <p>.
data: tabix like sy-tabix.

tabix = ( ofs div bdstab_linewidth ) + 1.
read table bdstab index tabix.
check sy-subrc = 0.
bdstab_lineofs = ofs mod bdstab_linewidth.
*assign bdstab+bdstab_lineofs(1) to <p> type 'X'.
assign bdstab to <p> type 'X'.
assign <p>+bdstab_lineofs(1) to <p>.
<p> = byte.
modify bdstab index tabix.
add 1 to ofs.
endform.

* write 16 bit unsigned int
form bdstab_put_2byte_int tables bdstab type sbdst_content
                          using int type i.
  statics: x type x.

  x = int div 256.
  perform bdstab_putbyte tables bdstab
                         using x.
  x = int mod 256.
  perform bdstab_putbyte tables bdstab
                         using x.
endform.

* write 16 bit unsigned int to filled BDSTAB
form bdstab_set_2byte_int tables bdstab type sbdst_content
                          using ofs type i
                                int type i.
statics: x type x.

x = int div 256.
perform bdstab_setbyte tables bdstab
                       using ofs x.
x = int mod 256.
perform bdstab_setbyte tables bdstab
                       using ofs x.
endform.

* write 32 bit unsigned int
form bdstab_put_4byte_int tables bdstab type sbdst_content
                          using int type i.
  statics: int2 type i.
  constants x10000 type i value 65536.

  int2 = int div x10000.
  perform bdstab_put_2byte_int tables bdstab
                               using int2.
  int2 = int mod x10000.
  perform bdstab_put_2byte_int tables bdstab
                               using int2.
endform.

* write 32 bit unsigned int to filled BDSTAB
form bdstab_set_4byte_int tables bdstab type sbdst_content
                          using ofs type i
                                int type i.
statics: int2 type i.
constants x10000 type i value 65536.

int2 = int div x10000.
perform bdstab_set_2byte_int tables bdstab
                             using ofs int2.
int2 = int mod x10000.
perform bdstab_set_2byte_int tables bdstab
                             using ofs int2.
endform.

* write 32 bit signed int
form bdstab_put_long tables bdstab type sbdst_content
                     using long type i.
  statics: word_lo type i,
           word_hi type i.
  constants: x10000 type i value 65536,
             x1000000 type i value 16777216.

  if long >= 0.
    word_lo = long mod x10000.
    word_hi = long div x10000.
  else.
    long = abs( long ).
    if long < x10000.
      word_hi = x10000 - 1.            "$ffff
      word_lo = x10000 - long.
    else.
*
    endif.
  endif.
  perform bdstab_put_2byte_int tables bdstab
                               using word_lo.
  perform bdstab_put_2byte_int tables bdstab
                               using word_hi.
endform.

* flush BDSTAB after writing last byte
form bdstab_flush tables bdstab type sbdst_content.
  if bdstab_lineofs > 0.
    append bdstab.
  endif.
endform.

* read byte from BDSTAB
form bdstab_getbyte tables bdstab type sbdst_content
                    using ofs type i
                          byte type x.
statics: bds_linelen type i,
         bds_lineofs type i,
         bds_tabix like sy-tabix.
field-symbols: <p>.

if bds_linelen = 0.
  describe field bdstab length bds_linelen
                               in byte mode.
endif.
bds_tabix = 1 + ofs div bds_linelen.
read table bdstab index bds_tabix.
check sy-subrc = 0.
bds_lineofs = ofs mod bds_linelen.
*assign bdstab+bds_lineofs(1) to <p> type 'X'.
assign bdstab to <p> type 'X'.
assign <p>+bds_lineofs(1) to <p>.
byte = <p>.
add 1 to ofs.
sy-subrc = 0.
endform.

form bdstab_get66bytes tables bdstab type sbdst_content
                       using ofs type i
                             66bytes type x
                             bytes_valid type i.
statics: bds_linelen type i,
         bds_lineofs type i,
         bds_tabix like sy-tabix.
constants: chunksize type i value 66.
field-symbols: <p>.

if bds_linelen = 0.
  describe field bdstab length bds_linelen
                               in byte mode.
endif.
if ofs = 0.
  bds_tabix = 1. bds_lineofs = 0.
  read table bdstab index bds_tabix.
endif.
bytes_valid = bds_linelen - bds_lineofs.
if bytes_valid >= chunksize.
* assign bdstab+bds_lineofs(chunksize) to <p> type 'X'.
  assign bdstab to <p> type 'X'.
  assign <p>+bds_lineofs(chunksize) to <p>.
  66bytes = <p>.
  add chunksize to bds_lineofs.
  bytes_valid = chunksize.
  ofs = ofs + chunksize.
else.
  if bytes_valid > 0.
*   assign bdstab+bds_lineofs(bytes_valid) to <p> type 'X'.
    assign bdstab to <p> type 'X'.
    assign <p>+bds_lineofs(bytes_valid) to <p>.
    66bytes = <p>.
    ofs = ofs + bytes_valid.
  endif.
  add 1 to bds_tabix.
  read table bdstab index bds_tabix.
  if sy-subrc = 0.
    bds_lineofs = chunksize - bytes_valid.
*    assign bdstab(bds_lineofs) to <p> type 'X'.
     assign bdstab to <p> type 'X'.
     assign <p>(bds_lineofs) to <p>.
    66bytes+bytes_valid(bds_lineofs) = <p>.
    ofs = ofs + bds_lineofs.
    bytes_valid = bytes_valid + bds_lineofs.
  endif.
endif.
endform.

* read 16 bit unsigned int from BDSTAB
form bdstab_get2byte_int tables bdstab type sbdst_content
                         using  ofs type i
                                int2 type i.
statics: x type x.

perform bdstab_getbyte tables bdstab
                       using ofs x.
int2 = 256 * x.
perform bdstab_getbyte tables bdstab
                       using ofs x.
int2 = int2 + x.
endform.

* read 32 bit unsigned int from BDSTAB
form bdstab_get4byte_int tables bdstab type sbdst_content
                         using  ofs type i
                                int4 type i.
statics: int2 type i.

perform bdstab_get2byte_int tables bdstab
                            using ofs int2.
int4 = 65536 * int2.
perform bdstab_get2byte_int tables bdstab
                            using ofs int2.
int4 = int4 + int2.
endform.

*******************************************************************
* maintaining linebuf (scanline byte buffer) for compression
*******************************************************************
form linebuf_init tables linebuf.
refresh linebuf. clear linebuf.
endform.

form linebuf_putbyte tables linebuf using value(byte) type x.
field-symbols <p>.
assign linebuf to <P> type 'X'.
<p> = byte. append linebuf.
endform.

form linebuf_getsize tables linebuf using bytecount.
describe table linebuf lines bytecount.
endform.

form linebuf_getbyte tables linebuf using byteofs type i
                                          byte type x.
field-symbols <p>.
assign linebuf to <p> type 'X'.
add 1 to byteofs.
read table linebuf index byteofs.
byte = <p>.
endform.

*******************************************************************
* compression functions
*******************************************************************
form comp_linebuf_writeeod tables bdstab type sbdst_content
                           using outcount.
statics byte type x.

byte = '80'.
perform bdstab_putbyte tables bdstab using byte.
add 1 to outcount.
endform.

form comp_linebuf_writelit tables linebuf
                                  bdstab type sbdst_content
                           using  value(linebuf_startofs)
                                  value(bytecount) type i
                                  outcount type i.
statics: byte type x.

while bytecount > 128.
  byte = 127.
  perform bdstab_putbyte tables bdstab using byte.
  do 128 times.
    perform linebuf_getbyte tables linebuf
                            using linebuf_startofs
                                  byte.
    perform bdstab_putbyte tables bdstab using byte.
  enddo.
  outcount = outcount + 1 + 128.
  bytecount = bytecount - 128.
endwhile.
byte = bytecount - 1.
perform bdstab_putbyte tables bdstab using byte.
do bytecount times.
  perform linebuf_getbyte tables linebuf
                            using linebuf_startofs
                                  byte.
  perform bdstab_putbyte tables bdstab using byte.
enddo.
outcount = outcount + 1 + bytecount.
endform.

form comp_linebuf_writerun tables linebuf
                                  bdstab type sbdst_content
                           using  value(runbyte) type x
                                  value(bytecount) type i
                                  outcount type i.
statics: byte type x.

while bytecount > 128.
  byte = '81'.
  perform bdstab_putbyte tables bdstab using byte.
  perform bdstab_putbyte tables bdstab using runbyte.
  bytecount = bytecount - 128.
  add 2 to outcount.
endwhile.
byte = 257 - bytecount.
perform bdstab_putbyte tables bdstab using byte.
perform bdstab_putbyte tables bdstab using runbyte.
add 2 to outcount.
endform.

form comp_linebuf_runl tables linebuf
                              bdstab type sbdst_content
                       using  value(comp_linebytes_in) type i
                              value(lastline) type ty_boolean
                              comp_linebytes_out type i.
statics: byte type x,
         oldbyte type x,
         runcount type i,
         runstartofs type i,
         ofs type i,
         state type c.
constants: c_state_start type c value 'A',
           c_state_next type c value 'B',
           c_state_lit type c value 'C',
           c_state_run type c value 'D',
           c_state_eodlit type c value 'E',
           c_state_eodrun type c value 'F'.

runcount = 0.
runstartofs = 0.
comp_linebytes_out = 0.
state = c_state_start.
ofs = 0.
do.
  case state.
    when c_state_start.
      runstartofs = ofs.
      perform linebuf_getbyte tables linebuf using ofs byte.
      if ofs >= comp_linebytes_in.
        state = c_state_eodlit.
      else.
        oldbyte = byte.
        state = c_state_next.
      endif.
    when c_state_next.
      perform linebuf_getbyte tables linebuf using ofs byte.
      if ofs >= comp_linebytes_in.
        if oldbyte = byte.
          state = c_state_eodrun.
        else.
          state = c_state_eodlit.
        endif.
      else.
        if byte = oldbyte.
          state = c_state_run.
        else.
          oldbyte = byte.
          state = c_state_lit.
        endif.
      endif.
    when c_state_lit.
      perform linebuf_getbyte tables linebuf using ofs byte.
      if ofs >= comp_linebytes_in.
        state = c_state_eodlit.
      else.
        if byte = oldbyte.
          runcount = ofs - runstartofs - 2.
          perform comp_linebuf_writelit tables linebuf
                                               bdstab
                                        using  runstartofs
                                               runcount
                                               comp_linebytes_out.
          runstartofs = ofs - 2.
          state = c_state_run.
        else.
          oldbyte = byte.
        endif.
      endif.
    when c_state_run.
      perform linebuf_getbyte tables linebuf using ofs byte.
      if byte <> oldbyte.
        runcount = ofs - runstartofs - 1.
        perform comp_linebuf_writerun tables linebuf
                                             bdstab
                                      using  oldbyte
                                             runcount
                                             comp_linebytes_out.
        runstartofs = ofs - 1.
        oldbyte = byte.
        state = c_state_next.
        if ofs >= comp_linebytes_in.
          state = c_state_eodlit.
        endif.
      else.
        if ofs >= comp_linebytes_in.
          state = c_state_eodrun.
        endif.
      endif.
    when c_state_eodlit.
      runcount = ofs - runstartofs.
      perform comp_linebuf_writelit tables linebuf
                                           bdstab
                                    using  runstartofs
                                           runcount
                                           comp_linebytes_out.
      if lastline = c_true.
        perform comp_linebuf_writeeod tables bdstab
                                      using comp_linebytes_out.
      endif.
      exit.
    when c_state_eodrun.
      runcount = ofs - runstartofs.
      perform comp_linebuf_writerun tables linebuf
                                           bdstab
                                    using  oldbyte
                                           runcount
                                           comp_linebytes_out.
      if lastline = c_true.
        perform comp_linebuf_writeeod tables bdstab
                                      using comp_linebytes_out.
      endif.
      exit.
  endcase.
enddo.
endform.

*********************************************************************
* ITF to *.BMP conversion, part 2
*********************************************************************
form convert_bm_to_bmp tables bmptab
                       using numbytes.
  constants: c_ascii_b type x value '42',
             c_ascii_m type x value '4D'.
  data: bmp_totalbytes type i,
        bmp_ofs_bits   type i, "offset between bitmapfileheader and bits
        pix_per_meter type i,
        ofs type i,
        bitmap_buffer_startofs type i,
        row type i,
        bmp_height type i,
        r type i,
        g type i,
        b type i,
        byte type x.

  perform bmptab_init tables bmptab.
* fill bitmap fileheader
  perform bmptab_putbyte tables bmptab                      "B
                         using c_ascii_b.
  perform bmptab_putbyte tables bmptab                      "M
                         using c_ascii_m.
  perform bmptab_putdword tables bmptab"filesize, not known
                          using bmp_totalbytes.
  perform bmptab_putword tables bmptab "reserved 1
                         using 0.
  perform bmptab_putword tables bmptab "reserved 2
                         using 0.
  perform bmptab_putdword tables bmptab"ofs to bitmap bits, not known
                          using bmp_ofs_bits.
* fill bitmap infoheader
  perform bmptab_putdword tables bmptab"sizeof infoheader in bytes
                            using 40.
  perform bmptab_putlong tables bmptab "width pixels
                         using otf_bminfo-w_pix.
  bmp_height = otf_bminfo-h_pix.       "bottom-up bitmap=positive height
  perform bmptab_putlong tables bmptab "height pixels
                         using bmp_height.
  perform bmptab_putword tables bmptab "number of planes
                         using 1.
  perform bmptab_putword tables bmptab "bitcount
                         using otf_bminfo-bitsperpix.
  perform bmptab_putdword tables bmptab"compression: BI_RGB
                          using 0.
  perform bmptab_putdword tables bmptab"sizeimage
                          using 0.
  pix_per_meter = ( otf_bminfo-dpi * 10000 ) / 254.
  perform bmptab_putlong tables bmptab "pixels per meter X
                         using pix_per_meter.
  perform bmptab_putlong tables bmptab "pixels per meter Y
                         using pix_per_meter.
  perform bmptab_putdword tables bmptab"colors used
                          using 0.
  perform bmptab_putdword tables bmptab"colors important
                          using 0.
* color table RGBQUAD array
  ofs = 0.
  if otf_bminfo-is_monochrome = c_true.  "monochrome
    byte = 'FF'.                       "white
    perform bmptab_putbyte tables bmptab
                           using byte.
    perform bmptab_putbyte tables bmptab
                           using byte.
    perform bmptab_putbyte tables bmptab
                           using byte.
    perform bmptab_putbyte tables bmptab
                           using '00'.
    byte = 0.                          "black
    perform bmptab_putbyte tables bmptab
                           using byte.
    perform bmptab_putbyte tables bmptab
                           using byte.
    perform bmptab_putbyte tables bmptab
                           using byte.
    perform bmptab_putbyte tables bmptab
                           using '00'.
  else.                                "color table
    do otf_bminfo-coltabsize times.
      perform bm_file_getword using ofs r. add 2 to ofs.
      perform bm_file_getword using ofs g. add 2 to ofs.
      perform bm_file_getword using ofs b. add 2 to ofs.
      byte = b div 256.
      perform bmptab_putbyte tables bmptab
                             using byte.
      byte = g div 256.
      perform bmptab_putbyte tables bmptab
                             using byte.
      byte = r div 256.
      perform bmptab_putbyte tables bmptab
                             using byte.
      perform bmptab_putbyte tables bmptab
                             using '00'.
    enddo.
  endif.
  bmp_ofs_bits = bitmap_file_bytecount.
* read bitmap bits from last to first row (turn top down bitmap
* into bottom-up bitmap)
  bitmap_buffer_startofs = ofs.
otf_bminfo-bytes_per_row = otf_bminfo-numdatabytes div otf_bminfo-h_pix.
  row = otf_bminfo-h_pix - 1.
  while row >= 0.
    ofs = bitmap_buffer_startofs + ( row * otf_bminfo-bytes_per_row ).
    do otf_bminfo-bytes_per_row times.
      perform bm_file_getbyte using ofs byte. add 1 to ofs.
      perform bmptab_putbyte tables bmptab
                             using byte.
    enddo.
    row = row - 1.
  endwhile.
  perform bmptab_flush tables bmptab.
  bmp_totalbytes = bitmap_file_bytecount.
* write totalbytes, ofs bits to BMP
  ofs = 2.
  perform bmptab_setdword_ofs tables bmptab
                              using ofs
                                    bmp_totalbytes.
  ofs = 10.
  perform bmptab_setdword_ofs tables bmptab
                              using ofs
                                    bmp_ofs_bits.
  numbytes = bmp_totalbytes.
endform.

*********************************************************************
* BMP to ITF conversion, part 1
* decode BMP format from BITMAP_FILE into BM_FILE
* fill OTF_BMINFO struct so info on bitmap is saved
*********************************************************************
form fill_bmfile_from_bmp tables bitmap_file
                          using  bytecount
                                 value(use_color).
  constants: c_ascii_b type x value '42',
             c_ascii_m type x value '4D'.
  data: ofs type i,
        byte type x,
        invert_pixels type ty_boolean,
        word type i,
        bmp_totalbytes type i,
        bmp_bisize     type i,
        bmp_width      type i,
        bmp_height     type i,
        bmp_bitcount   type i,
        bmp_compression type i,
        bmp_sizeimage  type i,
        bmp_xpelspermeter type i,
        bmp_ypelspermeter type i,
        ofs_bitmapinfoheader type i,
        ofs_rgbquad type i,
        ofs_bitmapdata type i,
        fullcolor_to_grayscale type ty_boolean,
        mod4 type i,
        rest type i.

  clear otf_bminfo.
  perform bmptab_init_readonly tables bitmap_file.
  ofs = 0.
***************************** bitmapfileheader *********************
* 'BM'
  perform bmptab_getbyte_ofs tables bitmap_file
                             using  ofs byte.
  if byte <> c_ascii_b.
    message e874 raising no_bmp_file.
  endif.
  perform bmptab_getbyte_ofs tables bitmap_file
                             using  ofs byte.
  if byte <> c_ascii_m.
    message e874 raising no_bmp_file.
  endif.
* total bytecount
  perform bmptab_getdword_ofs tables bitmap_file
                              using  ofs bmp_totalbytes.
* 2 reserved WORDs
  perform bmptab_getword_ofs tables bitmap_file
                             using  ofs word.
  perform bmptab_getword_ofs tables bitmap_file
                             using  ofs word.
* offset from FILEHEADER to bitmap bits
  perform bmptab_getdword_ofs tables bitmap_file
                              using  ofs ofs_bitmapdata.
*************************** bitmapinfoheader **********************
  ofs_bitmapinfoheader = ofs.
* sizeof(bitmapinfoheader)
  perform bmptab_getdword_ofs tables bitmap_file
                              using  ofs bmp_bisize.
* width in pixels
  perform bmptab_getlong_ofs tables bitmap_file
                          using ofs bmp_width.
* height in pixels (positive means bottom-up, negative means top-down)
  perform bmptab_getlong_ofs tables bitmap_file
                          using ofs bmp_height.
* planes, must be 1
  perform bmptab_getword_ofs tables bitmap_file
                             using  ofs word.
  if word <> 1.
    message e871 raising bmperr_invalid_format.
  endif.
* bitcount (bits per pixel)
  perform bmptab_getword_ofs tables bitmap_file
                             using  ofs bmp_bitcount.
  case bmp_bitcount.
    when 1.
      otf_bminfo-bmtype = c_itf_hex_bcol. "2 color
      otf_bminfo-is_monochrome = c_false.
    when 4.
      otf_bminfo-bmtype = c_itf_hex_bcol. "16 color
      otf_bminfo-is_monochrome = c_false.
    when 8.
      otf_bminfo-bmtype = c_itf_hex_bcol. "256 color
      otf_bminfo-is_monochrome = c_false.
    when 24.
      otf_bminfo-bmtype = c_itf_hex_bcol. "16 million colors
      otf_bminfo-is_monochrome = c_false.
    when others.  "16 or 32 bit true color
      message e875 with bmp_bitcount raising bmperr_no_colortable.
  endcase.
* compression
  perform bmptab_getdword_ofs tables bitmap_file
                              using  ofs bmp_compression.
  case bmp_compression.
    when c_bmp_compr_rgb.              "BI_RGB, uncompressed
    when c_bmp_compr_rle8. "BI_RLE8, 256 colors colormap, rle encoding
    when c_bmp_compr_rle4. "BI_RLE8, 16 colors colormap, rle encoding
    when others. message e872 raising bmperr_unsup_compression.
  endcase.
* size of image
  perform bmptab_getdword_ofs tables bitmap_file
                              using  ofs bmp_sizeimage.
* pix per meter X
  perform bmptab_getlong_ofs tables bitmap_file
                          using ofs bmp_xpelspermeter.
* pix per meter Y
  perform bmptab_getlong_ofs tables bitmap_file
                          using ofs bmp_ypelspermeter.
* colors used
  perform bmptab_getdword_ofs tables bitmap_file
                              using  ofs word.
* colors important
  perform bmptab_getdword_ofs tables bitmap_file
                              using  ofs word.
  ofs_rgbquad = ofs_bitmapinfoheader + bmp_bisize.
* now we have OFS_RGBQUAD    -> color table
*             OFS_BITMAPDATA -> bitmap bytes
  otf_bminfo-new_rd_format = c_false.
  otf_bminfo-is_resident   = c_false.
*--------------------------------------------------------------------*
* TuanBA delete
*--------------------------------------------------------------------*
*  otf_bminfo-dpi = ( bmp_xpelspermeter * 100 ) / 3937.
*--------------------------------------------------------------------*
* TuanBA add: Start
*--------------------------------------------------------------------*
  otf_bminfo-dpi = ( bmp_xpelspermeter / 3937 ) * 100  .
*--------------------------------------------------------------------*
* TuanBA add: End
*--------------------------------------------------------------------*

  perform bmp_adjust_dpi using otf_bminfo-dpi.
  otf_bminfo-w_pix = bmp_width.
  otf_bminfo-h_pix = abs( bmp_height ).
  otf_bminfo-w_tw = ( 1440 * otf_bminfo-w_pix ) / otf_bminfo-dpi.
  otf_bminfo-h_tw = ( 1440 * otf_bminfo-h_pix ) / otf_bminfo-dpi.
  case bmp_bitcount.
    when 1.
      otf_bminfo-bitsperpix = 1.
      otf_bminfo-bytes_per_row = otf_bminfo-w_pix div 8.
      rest = otf_bminfo-w_pix mod 8.
    when 4.
      otf_bminfo-bitsperpix = 4.
      otf_bminfo-bytes_per_row = otf_bminfo-w_pix div 2.
      rest = otf_bminfo-w_pix mod 2.
    when 8.
      otf_bminfo-bitsperpix = 8.
      otf_bminfo-bytes_per_row = otf_bminfo-w_pix.
      rest = 0.
    when 24.
      otf_bminfo-bytes_per_row_fullcolor = otf_bminfo-w_pix * 3.
      mod4 = otf_bminfo-bytes_per_row_fullcolor mod 4.
      if mod4 > 0.
        otf_bminfo-bytes_per_row_fullcolor =
          otf_bminfo-bytes_per_row_fullcolor + ( 4 - mod4 ).
      endif.
      if use_color = 'X'.
        otf_bminfo-bitsperpix = 8.
        otf_bminfo-bytes_per_row = otf_bminfo-w_pix. "256 colors
        rest = 0.
      else.
        otf_bminfo-bitsperpix = 1.
        otf_bminfo-bytes_per_row = otf_bminfo-w_pix div 8. "2 colors
        rest = otf_bminfo-w_pix mod 8.
      endif.
  endcase.
  if rest > 0.
*   make sure all pixels are contained
    add 1 to otf_bminfo-bytes_per_row.
  endif.
  otf_bminfo-bytes_per_row_act = otf_bminfo-bytes_per_row.
* adjust to 4 byte boundary
  mod4 = otf_bminfo-bytes_per_row mod 4.
  if mod4 > 0.
    otf_bminfo-bytes_per_row = otf_bminfo-bytes_per_row + ( 4 - mod4 ).
  endif.
  otf_bminfo-numdatabytes = otf_bminfo-bytes_per_row * otf_bminfo-h_pix.
  otf_bminfo-autoheight = c_true.
  otf_bminfo-res_h_tw   = otf_bminfo-h_tw.
* fill BM_FILE with color table, 2 color BMPs will have their color
* table rearranged/bytes inverted so that
*   color table index 0 (bit=0) means "light"
*   color table index 1 (bit=1) means "dark"
* we will invert bitmap pixels in this case
* this makes it easy to transform to monochrome
  perform bm_file_init.
  perform bmp_build_colormap tables bitmap_file
                             using ofs_rgbquad
                                   ofs_bitmapdata
                                   use_color
                                   bmp_bitcount
                                   bmp_height
                                   otf_bminfo-coltabsize
                                   invert_pixels
                                   fullcolor_to_grayscale.
  loop at bmp_color_tab.
    perform bm_file_putbyte using bmp_color_tab-r.
    perform bm_file_putbyte using bmp_color_tab-g.
    perform bm_file_putbyte using bmp_color_tab-b.
  endloop.
* fill BM_FILE with bitmap data from BITMAP_FILE (*.BMP format)
  if bmp_bitcount <= 8. "2,16,256 colors
    case bmp_compression.
      when c_bmp_compr_rgb.              "BI_RGB, uncompressed
      perform bmp_readpix_rgb tables bitmap_file
                              using ofs_bitmapdata
                                    bmp_height
                                    invert_pixels.
      when c_bmp_compr_rle8. "BI_RLE8, 256 colors colormap, rle encoding
      perform bmp_readpix_rle8 tables bitmap_file
                               using ofs_bitmapdata
                                     bmp_height
                                     bmp_sizeimage.
      when c_bmp_compr_rle4. "BI_RLE4, 16 colors colormap, rle encoding
      perform bmp_readpix_rle4 tables bitmap_file
                               using ofs_bitmapdata
                                     bmp_height
                                     bmp_sizeimage.
    endcase.
  else.                 "true color -> 256 colors
    perform bmp_readpix_fullcolor tables bitmap_file
                                  using ofs_bitmapdata
                                        bmp_height
                                        bmp_bitcount
                                        invert_pixels
                                        fullcolor_to_grayscale.
  endif.
  perform bm_file_flush.
endform.

* read true color pixels from BITMAP_FILE into BM_FILE table
form bmp_readpix_fullcolor tables bitmap_file
                           using value(ofs_bitmapdata) type i
                                 value(bmp_height) type i
                                 value(bmp_bitcount) type i
                          value(invert_pixels) type ty_boolean
                          value(fullcolor_to_grayscale) type ty_boolean.
data: ofs type i,
      row_bytes_written type i,
      curbyte type x,
      bitmask type x,
      x1 type x,
      x2 type x,
      x3 type x,
      intensity type i,
      row_ofs type i,
      inc type i,
      tabixn like sy-tabix,
      tabixo like sy-tabix.
field-symbols <p>.

if otf_bminfo-coltabsize = 2 or fullcolor_to_grayscale = c_true.
* 24bit color->monochrome or 24bit->256 level grayscale
  if bmp_height < 0. "top-down bitmap, same as in OTF
    row_ofs = ofs_bitmapdata.
    inc = otf_bminfo-bytes_per_row_fullcolor.
  else.              "bottom-up bitmap, reverse row sequence
    row_ofs = ofs_bitmapdata
            + otf_bminfo-h_pix * otf_bminfo-bytes_per_row_fullcolor
            - otf_bminfo-bytes_per_row_fullcolor.
    inc = 0 - otf_bminfo-bytes_per_row_fullcolor.
  endif.
  tabixo = 99999.
  do otf_bminfo-h_pix times.
    ofs = row_ofs. row_bytes_written = 0.
    curbyte = '00'. bitmask = '80'.
    do otf_bminfo-w_pix times.
********* blue
tabixn = ofs div bitmap_file_linewidth.
if tabixn <> tabixo.
   tabixo = tabixn.
   add 1 to tabixn.
   read table bitmap_file index tabixn.
   if sy-subrc <> 0.
     message e878 raising bmperr_eof.
   endif.
endif.
assign bitmap_file to <p> type 'X'.
bitmap_file_lineofs = ofs mod bitmap_file_linewidth.
x1 = <p>+bitmap_file_lineofs(1).
add 1 to ofs.
********* green
tabixn = ofs div bitmap_file_linewidth.
if tabixn <> tabixo.
   tabixo = tabixn.
   add 1 to tabixn.
   read table bitmap_file index tabixn.
   if sy-subrc <> 0.
     message e878 raising bmperr_eof.
   endif.
endif.
assign bitmap_file to <p> type 'X'.
bitmap_file_lineofs = ofs mod bitmap_file_linewidth.
x2 = <p>+bitmap_file_lineofs(1).
add 1 to ofs.
********* red
tabixn = ofs div bitmap_file_linewidth.
if tabixn <> tabixo.
   tabixo = tabixn.
   add 1 to tabixn.
   read table bitmap_file index tabixn.
   if sy-subrc <> 0.
     message e878 raising bmperr_eof.
   endif.
endif.
assign bitmap_file to <p> type 'X'.
bitmap_file_lineofs = ofs mod bitmap_file_linewidth.
x3 = <p>+bitmap_file_lineofs(1).
add 1 to ofs.
*********
*      perform bmptab_getbyte_ofs tables bitmap_file
*                                 using ofs x1. "blue
*      perform bmptab_getbyte_ofs tables bitmap_file
*                                 using ofs x2. "green
*      perform bmptab_getbyte_ofs tables bitmap_file
*                                 using ofs x3. "red
*     calculate 8 bit intensity value (0..255)
      intensity = ( 30 * x3 + 59 * x2 + 11 * x1 )
             div 100.
      case otf_bminfo-coltabsize.
        when 2.
          if intensity > 127. "white = 0
          else.               "black = 1
            curbyte = curbyte bit-or bitmask.
          endif.
          if bitmask = '01'. "rightmost bit
            perform bm_file_putbyte using curbyte.
            add 1 to row_bytes_written.
            bitmask = '80'. curbyte = '00'.
          else.
            bitmask = bitmask div 2.
          endif.
        when 256.
          curbyte = intensity.
          perform bm_file_putbyte using curbyte.
          add 1 to row_bytes_written.
      endcase.
    enddo.
    if not bitmask = '80'.
      perform bm_file_putbyte using curbyte.
      add 1 to row_bytes_written.
    endif.
    while row_bytes_written < otf_bminfo-bytes_per_row.
      perform bm_file_putbyte using '00'. "fill up to 4 byte border
      add 1 to row_bytes_written.
    endwhile.
    row_ofs = row_ofs + inc.
  enddo.
else.  "bm_file8bit has 8bit pixels
* 24bit color->8bit color
  ofs = 0.
  do otf_bminfo-h_pix times.
    row_bytes_written = 0.
    do otf_bminfo-w_pix times.
      perform bm_file8bit_getbyte using ofs curbyte.
      add 1 to ofs.
      perform bm_file_putbyte using curbyte.
      add 1 to row_bytes_written.
    enddo.
    while row_bytes_written < otf_bminfo-bytes_per_row.
      perform bm_file_putbyte using '00'. "fill up to 4 byte border
      add 1 to row_bytes_written.
    endwhile.
  enddo.
endif.
endform.

* read pixels from BITMAP_FILE into BM_FILE table, compression = RGB
form bmp_readpix_rgb tables bitmap_file
                     using value(bitmapdata_ofs)
                           value(bmp_height)
                           value(invert_pixels).
  data: ofs type i,
        row_ofs type i,
        byte type x.

  if bmp_height < 0.                   "top-down bitmap, same in OTF
    row_ofs = bitmapdata_ofs.
    do otf_bminfo-h_pix times.
      ofs = row_ofs.
      do otf_bminfo-bytes_per_row times.
        perform bmptab_getbyte_ofs tables bitmap_file
                                   using ofs byte.
        if invert_pixels = c_true.
          byte = byte bit-xor c_otf_rd_ff. "invert pixels
        endif.
        perform bm_file_putbyte using byte.
      enddo.
      row_ofs = row_ofs + otf_bminfo-bytes_per_row.
    enddo.
  else.              "bottom-up bitmap, reverse for OTF
    row_ofs = bitmapdata_ofs
            + otf_bminfo-h_pix * otf_bminfo-bytes_per_row
            - otf_bminfo-bytes_per_row.
    do otf_bminfo-h_pix times.
      ofs = row_ofs.
      do otf_bminfo-bytes_per_row times.
        perform bmptab_getbyte_ofs tables bitmap_file
                                   using ofs byte.
        if invert_pixels = c_true.
          byte = byte bit-xor c_otf_rd_ff. "invert pixels
        endif.
        perform bm_file_putbyte using byte.
      enddo.
      row_ofs = row_ofs - otf_bminfo-bytes_per_row.
    enddo.
  endif.
endform.

* read pixels from BITMAP_FILE into BM_FILE table, compression = RLE8
form bmp_readpix_rle8 tables bitmap_file
                      using value(bitmapdata_ofs)
                            value(bmp_height)
                            value(bmp_sizeimage).
  constants: c_x_00 type x value '00',
             c_x_01 type x value '01',
             c_x_02 type x value '02'.
  data: byte1 type x,
        byte2 type x,
        byte_horz type x,
        byte_vert type x,
        row type i,
        ofs type i,
        bytes_written type i,
        filler_bytes type i.

  if bmp_height < 0.
*   rle8 is only used with bottom-up bitmaps
    message e871 raising bmperr_invalid_format.
  endif.
  ofs = bitmapdata_ofs.
  row = 0.
  perform bm_file_tmp_init.
  bytes_written = 0.
  while row < otf_bminfo-h_pix.
    if bytes_written > bmp_sizeimage.  "corrupt rle data
      message e876 raising bmperr_corrupt_rle_data.
    endif.
    perform bmptab_getbyte_ofs tables bitmap_file
                               using ofs byte1.
    perform bmptab_getbyte_ofs tables bitmap_file
                               using ofs byte2.
    if byte1 = c_x_00.
      case byte2.
        when c_x_00.                   "end of line
          filler_bytes = otf_bminfo-bytes_per_row - bytes_written.
          if filler_bytes > 0.
            do filler_bytes times.
              perform bm_file_tmp_putbyte using c_x_00.
            enddo.
          endif.
          row = row + 1.
          bytes_written = 0.
        when c_x_01.                   "end of bitmap
          row = otf_bminfo-h_pix.
        when c_x_02.                   "delta
          perform bmptab_getbyte_ofs tables bitmap_file
                                     using ofs byte_horz.
          perform bmptab_getbyte_ofs tables bitmap_file
                                     using ofs byte_vert.
          if byte_vert > 0.
*         finish current row
            filler_bytes = otf_bminfo-bytes_per_row - bytes_written.
            do filler_bytes times.
              perform bm_file_tmp_putbyte using c_x_00.
            enddo.
            add 1 to row. bytes_written = 0.
*         skip n-1 rows
            byte_vert = byte_vert - 1.
            do byte_vert times.
              do otf_bminfo-bytes_per_row times.
                perform bm_file_tmp_putbyte using c_x_00.
              enddo.
              add byte_vert to row.
            enddo.
          endif.
*       skip to new column
          do byte_horz times.
            perform bm_file_tmp_putbyte using c_x_00.
            add 1 to bytes_written.
          enddo.
        when others.         "absolute mode, output following bytes
          do byte2 times.
            perform bmptab_getbyte_ofs tables bitmap_file
                                       using ofs byte_horz.
            perform bm_file_tmp_putbyte using byte_horz.
            add 1 to bytes_written.
          enddo.
          if byte2 o c_x_01. "consume padding byte for word-alignment
            perform bmptab_getbyte_ofs tables bitmap_file
                                       using ofs byte_horz.
          endif.
      endcase.
    else.                    "encoded mode, repeat byte2 BYTE1-times
      do byte1 times.
        perform bm_file_tmp_putbyte using byte2.
        add 1 to bytes_written.
      enddo.
    endif.
  endwhile.
  perform bm_file_tmp_flush using 'X'.
  perform bmp_reverse_row_ordering.    "*.BMP bottom-up -> ITF top-down
endform.

* read pixels from BITMAP_FILE into BM_FILE table, compression = RLE4
form bmp_readpix_rle4 tables bitmap_file
                      using value(bitmapdata_ofs)
                            value(bmp_height)
                            value(bmp_sizeimage).
  constants: c_x_00 type x value '00',
             c_x_01 type x value '01',
             c_x_02 type x value '02'.
  statics: byte1 type x,
           byte2 type x,
           pix1 type x,
           pix2 type x,
           byte_horz type x,
           byte_vert type x,
           row type i,
           ofs type i,
           bmpdataofs type i,
           bytes_written type i,
           pixels_written type i,
           filler_bytes type i,
           mod2 type i,
           firstnibble type c.

  ofs = bitmapdata_ofs.
  row = 0.
  bytes_written = 0.
  firstnibble = 'X'.
  while row < otf_bminfo-h_pix.
    if bytes_written > bmp_sizeimage.  "corrupt rle data
      message e876 raising bmperr_corrupt_rle_data.
    endif.
    perform bmptab_getbyte_ofs tables bitmap_file
                               using ofs byte1.
    perform bmptab_getbyte_ofs tables bitmap_file
                               using ofs byte2.
    if byte1 = c_x_00.
      case byte2.
        when c_x_00.                   "end of line
          filler_bytes = otf_bminfo-bytes_per_row - bytes_written.
          if filler_bytes > 0.
            do filler_bytes times.
              perform bm_file_tmp_putbyte using c_x_00.
            enddo.
          endif.
          row = row + 1.
          firstnibble = 'X'.
          bytes_written = 0.
        when c_x_01.                   "end of bitmap
          row = otf_bminfo-h_pix.
        when c_x_02.                   "delta
          perform bmptab_getbyte_ofs tables bitmap_file
                                     using ofs byte_horz.
          perform bmptab_getbyte_ofs tables bitmap_file
                                     using ofs byte_vert.
          if byte_vert > 0.
*         finish current row
            filler_bytes = otf_bminfo-bytes_per_row - bytes_written.
            do filler_bytes times.
              perform bm_file_tmp_putbyte using c_x_00.
            enddo.
            add 1 to row. bytes_written = 0.
*         skip n-1 rows
            byte_vert = byte_vert - 1.
            do byte_vert times.
              do otf_bminfo-bytes_per_row times.
                perform bm_file_tmp_putbyte using c_x_00.
              enddo.
              add byte_vert to row.
            enddo.
          endif.
*       skip to new column
          filler_bytes = byte_horz div 2.
          do filler_bytes times.
            perform bm_file_tmp_putbyte using c_x_00.
            add 1 to bytes_written.
          enddo.
          firstnibble = 'X'.
          if byte_horz o c_x_01.       "add 1 nibble
            perform bm_file_tmp_putnibble using c_x_00
                                                firstnibble.
            add 1 to bytes_written.
          endif.
        when others.         "absolute mode, output following bytes
          pixels_written = 0.
          while pixels_written < byte2.
            perform bmptab_getbyte_ofs tables bitmap_file
                                       using ofs byte_horz.
            pix1 = byte_horz div 16.
            pix2 = byte_horz mod 16.
            if firstnibble = 'X'.
              add 1 to bytes_written.
            endif.
            perform bm_file_tmp_putnibble using pix1
                                                firstnibble.
            add 1 to pixels_written.
            if pixels_written < byte2.
              if firstnibble = 'X'.
                add 1 to bytes_written.
              endif.
              perform bm_file_tmp_putnibble using pix2
                                                  firstnibble.
              add 1 to pixels_written.
            endif.
          endwhile.
          bmpdataofs = ofs - bitmapdata_ofs.
          mod2 = bmpdataofs mod 2.
          if mod2 = 1. "consume filler byte for word alignment
            perform bmptab_getbyte_ofs tables bitmap_file
                                       using ofs byte_horz.
          endif.
      endcase.
    else.                    "encoded mode, repeat 2 pixel from BYTE2
      pix1 = byte2 div 16.
      pix2 = byte2 mod 16.
      pixels_written = 0.
      while pixels_written < byte1.
        if firstnibble = 'X'.
          add 1 to bytes_written.
        endif.
        perform bm_file_tmp_putnibble using pix1
                                            firstnibble.
        add 1 to pixels_written.
        if pixels_written < byte1.
          if firstnibble = 'X'.
            add 1 to bytes_written.
          endif.
          perform bm_file_tmp_putnibble using pix2
                                              firstnibble.
          add 1 to pixels_written.
        endif.
      endwhile.
    endif.
  endwhile.
  perform bm_file_tmp_flush using firstnibble.
  perform bmp_reverse_row_ordering.    "*.BMP bottom-up -> ITF top-down
endform.

* reverse order of rows, copy from BM_FILE_TMP to BM_FILE
form bmp_reverse_row_ordering.
  data: row_ofs type i,
        ofs type i,
        byte type x.

  row_ofs = otf_bminfo-h_pix * otf_bminfo-bytes_per_row
          - otf_bminfo-bytes_per_row.
  do otf_bminfo-h_pix times.
    ofs = row_ofs.
    do otf_bminfo-bytes_per_row times.
      perform bm_file_tmp_getbyte using ofs byte.
      add 1 to ofs.
      perform bm_file_putbyte using byte.
    enddo.
    row_ofs = row_ofs - otf_bminfo-bytes_per_row.
  enddo.
endform.

* set dpi to a close supported value
form bmp_adjust_dpi using dpi.
  statics: delta type i,
           res type i,
           bestres type i,
           bestdelta type i.
  bestdelta = 10000. bestres = 600.
  do 6 times.
    case sy-index.
      when 1. res = 75.
      when 2. res = 100.
      when 3. res = 150.
      when 4. res = 200.
      when 5. res = 300.
      when 6. res = 600.
    endcase.
    delta = abs( dpi - res ).
    if delta < bestdelta.
      bestdelta = delta. bestres = res.
    endif.
  enddo.
  dpi = bestres.
endform.

form bmp_build_colormap tables bitmap_file
                               using value(ofs_rgb) type i
                                     value(ofs_pixels) type i
                                     value(use_color)
                                     value(bmp_bitcount) type i
                                     value(bmp_height) type i
                                     colormap_size type i
                                     invert_pixels type ty_boolean
                            fullcolor_to_grayscale type ty_boolean.
data: ofs type i,
      byte type x,
      red type x,
      green type x,
      blue type x,
      red1 type x,
      green1 type x,
      blue1 type x,
      intensity0 type i,
      intensity1 type i,
      numcolors type i.

refresh bmp_color_tab.
case bmp_bitcount.
  when 1.
*   2 color coltab
    ofs = ofs_rgb.
    colormap_size = 2.
    perform bmptab_getbyte_ofs tables bitmap_file
                               using ofs blue.
    perform bmptab_getbyte_ofs tables bitmap_file
                               using ofs green.
    perform bmptab_getbyte_ofs tables bitmap_file
                               using ofs red.
    add 1 to ofs.
    intensity0 = ( 30 * red + 59 * green + 11 * blue ) div 100.
    perform bmptab_getbyte_ofs tables bitmap_file
                               using ofs blue1.
    perform bmptab_getbyte_ofs tables bitmap_file
                               using ofs green1.
    perform bmptab_getbyte_ofs tables bitmap_file
                               using ofs red1.
    add 1 to ofs.
    intensity1 = ( 30 * red1 + 59 * green1 + 11 * blue1 ) div 100.
    if intensity0 > intensity1.
      bmp_color_tab-r = red.      "light
      bmp_color_tab-g = green.
      bmp_color_tab-b = blue.
      append bmp_color_tab.
      bmp_color_tab-r = red1.     "dark
      bmp_color_tab-g = green1.
      bmp_color_tab-b = blue1.
      append bmp_color_tab.
      invert_pixels = c_false.
    else.
      bmp_color_tab-r = red1.      "light
      bmp_color_tab-g = green1.
      bmp_color_tab-b = blue1.
      append bmp_color_tab.
      bmp_color_tab-r = red.       "dark
      bmp_color_tab-g = green.
      bmp_color_tab-b = blue.
      append bmp_color_tab.
      invert_pixels = c_true.
    endif.
  when 4.
*   16 color coltab
    ofs = ofs_rgb.
    colormap_size = 16.
    do colormap_size times.
      perform bmptab_getbyte_ofs tables bitmap_file
                                 using ofs bmp_color_tab-b.
      perform bmptab_getbyte_ofs tables bitmap_file
                                 using ofs bmp_color_tab-g.
      perform bmptab_getbyte_ofs tables bitmap_file
                                 using ofs bmp_color_tab-r.
      add 1 to ofs.
      append bmp_color_tab.
    enddo.
    invert_pixels = c_false.
  when 8.
*   256 color coltab
    ofs = ofs_rgb.
    colormap_size = 256.
    do colormap_size times.
      perform bmptab_getbyte_ofs tables bitmap_file
                                 using ofs bmp_color_tab-b.
      perform bmptab_getbyte_ofs tables bitmap_file
                                 using ofs bmp_color_tab-g.
      perform bmptab_getbyte_ofs tables bitmap_file
                                 using ofs bmp_color_tab-r.
      add 1 to ofs.
      append bmp_color_tab.
    enddo.
    invert_pixels = c_false.
  when 24.
*   24 bit true color->256 color
    if use_color = ' '.
      colormap_size = 2.
      byte = 'FF'. "white
      bmp_color_tab-r = bmp_color_tab-g = bmp_color_tab-b = byte.
      append bmp_color_tab.
      byte = '00'. "black
      bmp_color_tab-r = bmp_color_tab-g = bmp_color_tab-b = byte.
      append bmp_color_tab.
      fullcolor_to_grayscale = c_false.
    else.
      ofs = ofs_pixels.
      colormap_size = 256.
*     count colors actually used
      perform bmp_count_image_colors tables bitmap_file
                                     using ofs_pixels
                                           bmp_bitcount
                                           bmp_height
                                           numcolors.
      if numcolors < 257.
*       bmp_color_tab has been filled by BMP_COUNBT_IMAGE_COLORS
        fullcolor_to_grayscale = c_false.
        while numcolors < 256.
          append bmp_color_tab. add 1 to numcolors.
        endwhile.
      else.
*       build 256 entry grayscale color table
        fullcolor_to_grayscale = c_true.
        byte = 0.
        do 256 times.
          bmp_color_tab-r = bmp_color_tab-g = bmp_color_tab-b =
            byte.
          append bmp_color_tab.
          add 1 to byte.
        enddo.
      endif.
    endif.
endcase.
endform.

form bmp_count_image_colors tables bitmap_file
                            using value(ofs_pixels) type i
                                  value(bitsperpix) type i
                                  value(bmp_height) type i
                                  colorcount type i.
data: ofs type i,
      divisor type i,
      col type i,
      row type i,
      row_ofs type i,
      inc type i,
      x1 type x,
      x2 type x,
      x3 type x.
data: begin of loc_colmap occurs 100,
  truecolor type i,
  r type x,
  g type x,
  b type x,
      end of loc_colmap.
data: truecolor type i,
      r type x,
      g type x,
      b type x,
      pixel type x.

colorcount = 257.
check bitsperpix = 24.
do 2 times.
  if sy-index = 1.
*   24bit->12 bit per pixel -> 4096 colors
    divisor = 16. "256/16 -> 4 bit
  else.
*   24bit->9 bit per pixel  -> 512 colors
    divisor = 32. "256/32 -> 3 bit
  endif.
  perform bm_file8bit_init. "init intermediate buffer for 8-bit image
  colorcount = 0. refresh loc_colmap.
  if bmp_height < 0. "top-down bitmap, same in OTF
    row_ofs = ofs_pixels.
    inc = otf_bminfo-bytes_per_row_fullcolor.
  else.              "bottom-up bitmap, reverse row ordering
    row_ofs = ofs_pixels
            + otf_bminfo-h_pix * otf_bminfo-bytes_per_row_fullcolor
            - otf_bminfo-bytes_per_row_fullcolor.
    inc = 0 - otf_bminfo-bytes_per_row_fullcolor.
  endif.
  do otf_bminfo-h_pix times.
    if colorcount > 256. exit. endif.
    ofs = row_ofs.
    do otf_bminfo-w_pix times.
      perform bmptab_getbyte_ofs tables bitmap_file
                                 using ofs x1. "blue
      perform bmptab_getbyte_ofs tables bitmap_file
                                 using ofs x2. "green
      perform bmptab_getbyte_ofs tables bitmap_file
                                 using ofs x3. "red
      r = x3 div divisor.
      g = x2 div divisor.
      b = x1 div divisor.
      truecolor = r * 65536 + g * 256 + b.
      read table loc_colmap with key truecolor = truecolor.
      if sy-subrc = 0.
        pixel = sy-tabix - 1.
      else.
        add 1 to colorcount.
        if colorcount > 256. exit. endif.
        loc_colmap-truecolor = truecolor.
        loc_colmap-r = r.
        loc_colmap-g = g.
        loc_colmap-b = b.
        append loc_colmap.
        pixel = colorcount - 1.
      endif.
*     save pixel
      perform bm_file8bit_putbyte using pixel.
    enddo.
    row_ofs = row_ofs + inc.
  enddo.
  perform bm_file8bit_flush.
  if colorcount <= 256.
    refresh bmp_color_tab.
    loop at loc_colmap.
      bmp_color_tab-r = loc_colmap-r * divisor.
      bmp_color_tab-g = loc_colmap-g * divisor.
      bmp_color_tab-b = loc_colmap-b * divisor.
      append bmp_color_tab.
    endloop.
    exit.
  endif.
enddo.
endform.

*********************************************************************
* .TIF to ITF conversion, part 1
* decode TIF format from BITMAP_FILE into BM_FILE
* fill OTF_BMINFO struct so info on bitmap is saved
*********************************************************************
form fill_bmfile_from_tif tables bitmap_file
                          using  bytecount
                                 use_color.
data: ofs TYPE I,
      NEXTIFDOFS TYPE I,
      h_dpi type i,
      v_dpi type i,
      rest type i,
      mod4 type i,
      invert_pixels type ty_boolean,
      red type x,
      green type x,
      blue type x,
      byte1 type x,
      byte2 type x,
      fullcolor_to_grayscale.

clear otf_bminfo.
perform bmptab_init_readonly tables bitmap_file.
* set baseline TIFF 6.0 defaults
CLEAR TIF_INFO. refresh tif_color_tab.
TIF_INFO-FILLORDER = 1.
TIF_INFO-PHOTOMETRIC = 0.
* get byte order
ofs = 0.
perform bmptab_getbyte_ofs tables bitmap_file
                           using  ofs byte1.
perform bmptab_getbyte_ofs tables bitmap_file
                           using  ofs byte2.
IF byte1 = '49' AND byte2 = '49'.
  TIF_INFO-BYTEORDER = C_BYTEORD_INTEL.
ELSEIF byte1 = '4D' AND byte2 = '4D'.
  TIF_INFO-BYTEORDER = C_BYTEORD_MOTO.
ELSE.
  MESSAGE E880 RAISING tifferr_invalid_format.
  exit.
ENDIF.
* get VERSION number
perform bmptab_getword_ofs tables bitmap_file
                           using ofs tif_info-version.
IF TIF_INFO-VERSION <> 42.
  MESSAGE E880 RAISING tifferr_invalid_format.
  EXIT.
ENDIF.
* get first IFD offset
perform bmptab_getdword_ofs tables bitmap_file
                            using ofs tif_info-firstifdofs.
* read 1st IFD
PERFORM TIF_READ_IFD tables bitmap_file
                     USING TIF_INFO-FIRSTIFDOFS NEXTIFDOFS.
* set "important" OTF_BMINFO fields
otf_bminfo-new_rd_format = c_false.
otf_bminfo-is_resident   = c_false.
* calculate resolution
IF TIF_INFO-XRES_D > 0 AND TIF_INFO-XRES_N > 0.
  H_DPI = TIF_INFO-XRES_N / TIF_INFO-XRES_D.
  IF TIF_INFO-RESUNIT = 3. "dots / cm -> dots / inch
    H_DPI = H_DPI * 254 / 100.
  ENDIF.
ENDIF.
IF TIF_INFO-YRES_D > 0 AND TIF_INFO-YRES_N > 0.
  V_DPI = TIF_INFO-YRES_N / TIF_INFO-YRES_D.
  IF TIF_INFO-RESUNIT = 3. "dots / cm -> dots / inch
    V_DPI = V_DPI * 254 / 100.
  ENDIF.
ENDIF.
IF H_DPI <> V_DPI.
  MESSAGE E880 RAISING tifferr_invalid_format.
ENDIF.
TIF_INFO-DPI = H_DPI.
otf_bminfo-dpi = tif_info-dpi.
perform bmp_adjust_dpi using otf_bminfo-dpi.
otf_bminfo-w_pix = tif_info-width.
otf_bminfo-h_pix = tif_info-length.
otf_bminfo-w_tw = ( 1440 * otf_bminfo-w_pix ) / otf_bminfo-dpi.
otf_bminfo-h_tw = ( 1440 * otf_bminfo-h_pix ) / otf_bminfo-dpi.
* determine color depth, bitcount etc.
perform tif_determine_tiftype.
if sy-subrc <> 0.
  MESSAGE E880 RAISING tifferr_invalid_format.
endif.
* add color maps for bilevel, grayscale, fullcolor images
perform tif_build_colormap tables bitmap_file
                           using invert_pixels
                                 use_color
                                 fullcolor_to_grayscale.
* calculate bytes per row
case otf_bminfo-bitsperpix.
  when 1.
    otf_bminfo-coltabsize = 2.
    otf_bminfo-bytes_per_row = otf_bminfo-w_pix div 8.
    rest = otf_bminfo-w_pix mod 8.
  when 4.
    otf_bminfo-coltabsize = 16.
    otf_bminfo-bytes_per_row = otf_bminfo-w_pix div 2.
    rest = otf_bminfo-w_pix mod 2.
  when 8.
    otf_bminfo-coltabsize = 256.
    otf_bminfo-bytes_per_row = otf_bminfo-w_pix.
    rest = 0.
endcase.
if rest > 0.
  add 1 to otf_bminfo-bytes_per_row. "make sure all pixels are contained
endif.
otf_bminfo-bytes_per_row_act = otf_bminfo-bytes_per_row.
* adjust to 4 byte boundary
mod4 = otf_bminfo-bytes_per_row mod 4.
if mod4 > 0.
  otf_bminfo-bytes_per_row = otf_bminfo-bytes_per_row + ( 4 - mod4 ).
endif.
otf_bminfo-numdatabytes = otf_bminfo-bytes_per_row * otf_bminfo-h_pix.
otf_bminfo-autoheight = c_true.
otf_bminfo-res_h_tw   = otf_bminfo-h_tw.
* write color table
if tif_info-colormap_size <> otf_bminfo-coltabsize.
  MESSAGE E880 RAISING tifferr_invalid_format.
endif.
perform bm_file_init.
loop at tif_color_tab.
  red = tif_color_tab-r div 256.
  green = tif_color_tab-g div 256.
  blue = tif_color_tab-b div 256.
  perform bm_file_putbyte using red.
  perform bm_file_putbyte using green.
  perform bm_file_putbyte using blue.
endloop.
* build BM_FILE table from TIFF file data
if otf_bminfo-is_monochrome = 'X'.
  otf_bminfo-bmtype = C_ITF_HEX_BMON.
else.
  otf_bminfo-bmtype = C_ITF_HEX_BCOL.
endif.
perform tif_write_bmfile_pixels tables bitmap_file
                                using invert_pixels
                                      fullcolor_to_grayscale.
endform.

form tif_determine_tiftype.
* check if we can decode the file at all...
IF TIF_INFO-WIDTH = 0 OR TIF_INFO-LENGTH = 0.
  SY-SUBRC = 1. EXIT.
ENDIF.
IF TIF_INFO-NUMBER_STRIPS < 1.
  SY-SUBRC = 1. EXIT.
ENDIF.
IF TIF_INFO-FILLORDER <> 1.
  SY-SUBRC = 1. EXIT.
ENDIF.
* find out which type of TIFF file we have
TIF_INFO-TIFTYPE = C_TIFTYPE_NONE.
IF TIF_INFO-PHOTOMETRIC = 0 OR TIF_INFO-PHOTOMETRIC = 1.
  IF TIF_INFO-BITSPERSAMPLEPLANES < 1.
    IF TIF_INFO-COMPRESSION = C_COMP_UNCOMP OR
       TIF_INFO-COMPRESSION = C_COMP_HUFFMAN OR
       TIF_INFO-COMPRESSION = C_COMP_PACKBITS.
      TIF_INFO-TIFTYPE = C_TIFTYPE_BILEVEL.
    ENDIF.
  ELSE.
    IF TIF_INFO-BITSPERSAMPLEPLANES = 1.
      IF TIF_INFO-BITSPERSAMPLE_1 = 1.
        IF TIF_INFO-COMPRESSION = C_COMP_UNCOMP OR
           TIF_INFO-COMPRESSION = C_COMP_HUFFMAN OR
           TIF_INFO-COMPRESSION = C_COMP_PACKBITS.
          TIF_INFO-TIFTYPE = C_TIFTYPE_BILEVEL.
        ENDIF.
      ENDIF.
      IF TIF_INFO-BITSPERSAMPLE_1 = 4 OR TIF_INFO-BITSPERSAMPLE_1 = 8.
        IF TIF_INFO-COMPRESSION = C_COMP_UNCOMP OR
           TIF_INFO-COMPRESSION = C_COMP_PACKBITS.
          TIF_INFO-TIFTYPE = C_TIFTYPE_GRAYSCALE.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ELSEIF TIF_INFO-PHOTOMETRIC = 2.
  IF TIF_INFO-BITSPERSAMPLEPLANES = 3 AND
    TIF_INFO-BITSPERSAMPLE_1 = 8 AND
    TIF_INFO-BITSPERSAMPLE_2 = 8 AND
    TIF_INFO-BITSPERSAMPLE_3 = 8.
    IF TIF_INFO-COMPRESSION = C_COMP_UNCOMP OR
       TIF_INFO-COMPRESSION = C_COMP_PACKBITS.
      IF TIF_INFO-SAMPLESPERPIX = 3.
        TIF_INFO-TIFTYPE = C_TIFTYPE_FULLCOLOR.
      ENDIF.
    ENDIF.
  ENDIF.
ELSEIF TIF_INFO-PHOTOMETRIC = 3.
  IF TIF_INFO-BITSPERSAMPLEPLANES = 1 AND
    ( TIF_INFO-BITSPERSAMPLE_1 = 4 OR TIF_INFO-BITSPERSAMPLE_1 = 8 ).
    IF TIF_INFO-COMPRESSION = C_COMP_UNCOMP OR
       TIF_INFO-COMPRESSION = C_COMP_PACKBITS.
      TIF_INFO-TIFTYPE = C_TIFTYPE_COLORMAP.
    ENDIF.
  ENDIF.
ENDIF.
* determine number of rows to examine in a single strip
IF TIF_INFO-NUMBER_STRIPS = 1.
  TIF_INFO-MAXROW = TIF_INFO-LENGTH.
ELSE.
  TIF_INFO-MAXROW = TIF_INFO-ROWSPERSTRIP.
ENDIF.
* determine number of pixel columns in a row
TIF_INFO-MAXCOL = TIF_INFO-WIDTH.
if tif_info-tiftype = c_tiftype_none.
  sy-subrc = 1.
else.
  sy-subrc = 0.
endif.
endform.

form tif_build_colormap tables bitmap_file
                        using invert_pixels
                              value(use_color)
                              fullcolor_to_grayscale.
data: intensity type i,
      start_intensity type i,
      inc type i,
      colorcount type i.

invert_pixels = C_FALSE.
case tif_info-tiftype.
  when c_tiftype_bilevel.
    otf_bminfo-bitsperpix = 1.
    otf_bminfo-is_monochrome = C_FALSE.
    if tif_info-photometric = 1. "black is zero
      invert_pixels = C_TRUE.
    else.                        "white is zero
      invert_pixels = C_FALSE.
    endif.
*   build black+white color table where entry 0 = white and entry
*   1 = black. This makes it easy to move to monochrome
    refresh tif_color_tab.
    tif_color_tab-r = tif_color_tab-g = tif_color_tab-b = 256 * 255.
    append tif_color_tab.
    tif_color_tab-r = tif_color_tab-g = tif_color_tab-b = 0.
    append tif_color_tab.
    tif_info-colormap_size = 2.

  when c_tiftype_grayscale.
    case tif_info-bitspersample_1.
      when 4. otf_bminfo-bitsperpix = 4. tif_info-colormap_size = 16.
      when 8. otf_bminfo-bitsperpix = 8. tif_info-colormap_size = 256.
    endcase.
    otf_bminfo-is_monochrome = C_false.
*   build grayscale color table
    if tif_info-photometric = 1. "black is zero
      start_intensity = 0.
      inc = 65535 div tif_info-colormap_size.
    else.                        "white is zero
      start_intensity = 65535.
      inc = 0 - 65535 div tif_info-colormap_size.
    endif.
    intensity = start_intensity.
    refresh tif_color_tab.
    do tif_info-colormap_size times.
      tif_color_tab-r = tif_color_tab-g = tif_color_tab-b = intensity.
      append tif_color_tab.
      intensity = intensity + inc.
    enddo.

  when c_tiftype_fullcolor.
    refresh tif_color_tab.
    if use_color = space.
      otf_bminfo-bitsperpix = 1. tif_info-colormap_size = 2.
      otf_bminfo-is_monochrome = C_FALSE.
*     build black+white color table where entry 0 = white and entry
*     1 = black. This makes it easy to move to monochrome
      tif_color_tab-r = tif_color_tab-g = tif_color_tab-b = 256 * 255.
      append tif_color_tab.
      tif_color_tab-r = tif_color_tab-g = tif_color_tab-b = 0.
      append tif_color_tab.
    else.
      otf_bminfo-bitsperpix = 8. tif_info-colormap_size = 256.
      otf_bminfo-is_monochrome = C_false.
      perform tif_count_image_colors tables bitmap_file
                                     using colorcount.
      if colorcount <= 256.
*       TIF_COLOR_TAB has already been filled by tif_count_..
        fullcolor_to_grayscale = ' '.
        while colorcount < 256.
          append tif_color_tab. add 1 to colorcount.
        endwhile.
      else.
        fullcolor_to_grayscale = 'X'.
*       build 256 entry grayscale color table
        inc = 256.
        intensity = 0.
        do tif_info-colormap_size times.
          tif_color_tab-r = tif_color_tab-g = tif_color_tab-b
            = intensity.
          append tif_color_tab.
          intensity = intensity + inc.
        enddo.
      endif.
    endif.

  when c_tiftype_colormap.
    otf_bminfo-is_monochrome = C_false.
    otf_bminfo-bitsperpix = tif_info-bitspersample_1. "4 or 8
endcase.
endform.

* for full color TIFF images, count colors to build 256 entries
* color map (avoiding grayscale transformation)
* try:
* 1) reduce 24 bit RGB to 12 bit RGB
* 2) reduce 24 bit RGB to 9 bit RGB
* save 8-bit bitmap in BM_FILE8BIT buffer
FORM tif_count_image_colors tables bitmap_file
                             using colorcount.
data: OFS TYPE I,
      GLOB_X1 type X, GLOB_X2 type X, GLOB_X3 type X,
      COL TYPE I, ROW TYPE I,
      firstcol type ty_boolean,
      divisor type i.
data: begin of loc_colmap occurs 100,
  truecolor type i,
  r type x,
  g type x,
  b type x,
      end of loc_colmap.
data: truecolor type i,
      r type x,
      g type x,
      b type x,
      pixel type x.

colorcount = 257.
check TIF_INFO-TIFTYPE = C_TIFTYPE_FULLCOLOR.
do 2 times.
  if sy-index = 1.
*   24bit->12 bit per pixel
    divisor = 16. "256/16 -> 4 bit
  else.
*   24bit->9 bit per pixel
    divisor = 32. "256/32 -> 3 bit
  endif.
  perform bm_file8bit_init. "init intermediate buffer for 8-bit image
  colorcount = 0. refresh loc_colmap.
  row = 0.
  LOOP AT TIF_STRIPOFS_TAB.
    if colorcount > 256. exit. endif.
    OFS = TIF_STRIPOFS_TAB-OFS.
    DO TIF_INFO-MAXROW TIMES.
      if colorcount > 256. exit. endif.
      ADD 1 TO ROW.
      CHECK ROW <= TIF_INFO-LENGTH.
      COL = 0.
      WHILE COL < TIF_INFO-MAXCOL.
        CASE TIF_INFO-COMPRESSION.
          WHEN C_COMP_UNCOMP.
          perform bmptab_getbyte_ofs tables bitmap_file
                                     using ofs glob_x1.
          perform bmptab_getbyte_ofs tables bitmap_file
                                     using ofs glob_x2.
          perform bmptab_getbyte_ofs tables bitmap_file
                                     using ofs glob_x3.
        WHEN C_COMP_PACKBITS.
          IF OFS = TIF_STRIPOFS_TAB-OFS. "first byte in strip
            firstcol = c_true.
          else.
            firstcol = c_false.
          endif.
          perform bmtab_getbyte_packbits tables bitmap_file
                                         USING ofs
                                         tif_stripofs_tab-ofs
                                         firstcol
                                         glob_x1.
          perform bmtab_getbyte_packbits tables bitmap_file
                                         USING ofs
                                         tif_stripofs_tab-ofs
                                         c_false
                                         glob_x2.
          perform bmtab_getbyte_packbits tables bitmap_file
                                         USING ofs
                                         tif_stripofs_tab-ofs
                                         c_false
                                         glob_x3.
        ENDCASE.
        add 1 to col.
*       true color->indexed: check if we have had this color before
        r = glob_x1 div divisor.
        g = glob_x2 div divisor.
        b = glob_x3 div divisor.
        truecolor = r * 65536 + g * 256 + b.
        read table loc_colmap with key truecolor = truecolor.
        if sy-subrc = 0.
          pixel = sy-tabix - 1.
        else.
          add 1 to colorcount.
          if colorcount > 256. exit. endif.
          loc_colmap-truecolor = truecolor.
          loc_colmap-r = r.
          loc_colmap-g = g.
          loc_colmap-b = b.
          append loc_colmap.
          pixel = colorcount - 1.
        endif.
*       save pixel
        perform bm_file8bit_putbyte using pixel.
      endwhile.
    ENDDO.
  ENDLOOP.
  perform bm_file8bit_flush.
  if colorcount <= 256.
    loop at loc_colmap.
      tif_color_tab-r = 256 * loc_colmap-r * divisor.
      tif_color_tab-g = 256 * loc_colmap-g * divisor.
      tif_color_tab-b = 256 * loc_colmap-b * divisor.
      append tif_color_tab.
    endloop.
    exit.
  endif.
enddo.
ENDFORM.

FORM tif_write_bmfile_pixels tables bitmap_file
                             using value(invert_pixels)
                                   value(fullcolor_to_grayscale).
data: OFS TYPE I,
      GLOB_X1 type X, GLOB_X2 type X, GLOB_X3 type X,
      INTENSITY TYPE I, CURBYTE TYPE X,
      hi_nibble type x, lo_nibble type x,
      COL TYPE I, ROW TYPE I, MOD2 TYPE I, mod8 type i,
      PIXELS_PER_BYTE TYPE I, NUMPIXELS TYPE I, STRIPBYTES TYPE I,
      row_bytes_written type i,
      firstcol type ty_boolean,
      rem_col type i,
      bitmask type x,
      r type i,
      g type i,
      b type i.

CASE TIF_INFO-TIFTYPE.
  WHEN C_TIFTYPE_BILEVEL.
*   bilevel (black and white) image
*   1 bit per pixel, 8 pixel in a byte
*   loop over image data strips and fill pixel table
*   CAUTION: every strip contains TIF_INFO-ROWSPERSTRIP rows except
*   the last one which may contain fewer rows
    ROW = 0.
    LOOP AT TIF_STRIPOFS_TAB.
      OFS = TIF_STRIPOFS_TAB-OFS.
      DO TIF_INFO-MAXROW TIMES.
        ADD 1 TO ROW.
        CHECK ROW <= TIF_INFO-LENGTH.
        COL = 0. row_bytes_written = 0.
        WHILE COL < TIF_INFO-MAXCOL.
          CASE TIF_INFO-COMPRESSION.
            WHEN C_COMP_UNCOMP.
              perform bmptab_getbyte_ofs tables bitmap_file
                                         using ofs glob_x1.
            WHEN C_COMP_HUFFMAN.
              message E872 raising tifferr_unsup_compression.
            WHEN C_COMP_PACKBITS.
              IF OFS = TIF_STRIPOFS_TAB-OFS. "first byte in strip
                firstcol = c_true.
              else.
                firstcol = c_false.
              endif.
              perform bmtab_getbyte_packbits tables bitmap_file
                                             USING ofs
                                             tif_stripofs_tab-ofs
                                             firstcol
                                             glob_x1.
          ENDCASE.
          if invert_pixels = C_true.
            glob_x1 = glob_x1 bit-xor c_otf_rd_ff.
            rem_col = tif_info-maxcol - col.
            if rem_col <= 8.
              mod8 = tif_info-maxcol mod 8.
              case mod8.
                when 0. bitmask = 'FF'. "all bits are valid
                when 1. bitmask = '80'. "bit 7
                when 2. bitmask = 'C0'. "bits 7+6
                when 3. bitmask = 'E0'. "bits 7+6+5
                when 4. bitmask = 'F0'. "bits 7+6+5+4
                when 5. bitmask = 'F8'. "bits 7-3
                when 6. bitmask = 'FC'. "bits 7-2
                when 7. bitmask = 'FE'. "bits 7-1
              endcase.
              glob_x1 = glob_x1 bit-and bitmask.
            endif.
          endif.
          perform bm_file_putbyte using glob_x1.
          add 8 to col.
          add 1 to row_bytes_written.
        ENDWHILE.
        while row_bytes_written < otf_bminfo-bytes_per_row.
          perform bm_file_putbyte using '00'. "fill to 4 bytes
          add 1 to row_bytes_written.
        endwhile.
      ENDDO.
    ENDLOOP.

  WHEN C_TIFTYPE_GRAYSCALE.
*   grayscale image with 0..15 or 0..255 pixel values
*   4-bit pixels are normally packed 2 pixel into one byte, but they can
*   also appear as 1 pixel per byte
*   loop over image data strips and fill pixel table
*   CAUTION: every strip contains TIF_INFO-ROWSPERSTRIP rows except
*   the last one which may contain fewer rows
    IF TIF_INFO-BITSPERSAMPLE_1 = 4.
      NUMPIXELS = TIF_INFO-WIDTH * TIF_INFO-LENGTH.
      STRIPBYTES = 0.
      LOOP AT TIF_STRIPOFS_TAB.
        ADD TIF_STRIPOFS_TAB-COUNT TO STRIPBYTES.
      ENDLOOP.
      IF STRIPBYTES >= NUMPIXELS.
        PIXELS_PER_BYTE = 1. "4 bits per pixel
      ELSE.
        PIXELS_PER_BYTE = 2. "4 bits per pixel
      ENDIF.
    ELSE.
      PIXELS_PER_BYTE = 1. "8 bits per pixel
    ENDIF.
    ROW = 0.
    LOOP AT TIF_STRIPOFS_TAB.
      OFS = TIF_STRIPOFS_TAB-OFS.
      DO TIF_INFO-MAXROW TIMES.
        ADD 1 TO ROW.
        CHECK ROW <= TIF_INFO-LENGTH.
        COL = 0. row_bytes_written = 0.
        WHILE COL < TIF_INFO-MAXCOL.
          CASE TIF_INFO-COMPRESSION.
            WHEN C_COMP_UNCOMP.
              perform bmptab_getbyte_ofs tables bitmap_file
                                         using ofs glob_x1.
            WHEN C_COMP_PACKBITS.
              IF OFS = TIF_STRIPOFS_TAB-OFS. "first byte in strip
                firstcol = c_true.
              else.
                firstcol = c_false.
              endif.
              perform bmtab_getbyte_packbits tables bitmap_file
                                             USING ofs
                                             tif_stripofs_tab-ofs
                                             firstcol
                                             glob_x1.
          ENDCASE.
          case tif_info-bitspersample_1.
            when 8. "8 bits per pixel, one pixel per byte
              perform bm_file_putbyte using glob_x1.
              ADD 1 TO COL.
              add 1 to row_bytes_written.
            when 4. "4 bits per pixel, one or two pixels per byte
              IF PIXELS_PER_BYTE = 2.
                perform bm_file_putbyte using glob_x1.
                ADD 2 TO COL.
                add 1 to row_bytes_written.
              ELSE.
                mod2 = col mod 2.
                if mod2 = 0. "even column, save hi_nibble
                  hi_nibble = glob_x1 mod 16.
                else.        "odd column, combine hi,lo nibble
                  lo_nibble = glob_x1 mod 16.
                  glob_x1 = 16 * hi_nibble + lo_nibble.
                  perform bm_file_putbyte using glob_x1.
                  ADD 2 TO COL.
                  add 1 to row_bytes_written.
                endif.
              endif.
          endcase.
        ENDWHILE.
        while row_bytes_written < otf_bminfo-bytes_per_row.
          perform bm_file_putbyte using '00'. "fill up to 4 byte border
          add 1 to row_bytes_written.
        endwhile.
      ENDDO.
    ENDLOOP.

  WHEN C_TIFTYPE_FULLCOLOR.
* TIFF fullcolor images that we can convert have 24-bit RGB color data
* we need to convert each 24-bit pixel to either
*   black (1) or white (0) (if a monochrome image is requested)
* OR
*   0..255 grayscale intensity (8 bit colindex) if more than 256 colors
* OR
*   copy BM_FILE8BIT buffer if 24bit->8 bit conv. was successful
  if tif_info-colormap_size = 2 or fullcolor_to_grayscale = 'X'.
*   24bit color->monochrome or 24bit->256 level grayscale
    row = 0.
    LOOP AT TIF_STRIPOFS_TAB.
      OFS = TIF_STRIPOFS_TAB-OFS.
      DO TIF_INFO-MAXROW TIMES.
        ADD 1 TO ROW.
        CHECK ROW <= TIF_INFO-LENGTH.
        COL = 0. row_bytes_written = 0.
        curbyte = '00'. bitmask = '80'.
        WHILE COL < TIF_INFO-MAXCOL.
          CASE TIF_INFO-COMPRESSION.
            WHEN C_COMP_UNCOMP.
              perform bmptab_getbyte_ofs tables bitmap_file
                                         using ofs glob_x1.
              perform bmptab_getbyte_ofs tables bitmap_file
                                         using ofs glob_x2.
              perform bmptab_getbyte_ofs tables bitmap_file
                                         using ofs glob_x3.
            WHEN C_COMP_PACKBITS.
              IF OFS = TIF_STRIPOFS_TAB-OFS. "first byte in strip
                firstcol = c_true.
              else.
                firstcol = c_false.
              endif.
              perform bmtab_getbyte_packbits tables bitmap_file
                                             USING ofs
                                             tif_stripofs_tab-ofs
                                             firstcol
                                             glob_x1.
              perform bmtab_getbyte_packbits tables bitmap_file
                                             USING ofs
                                             tif_stripofs_tab-ofs
                                             c_false
                                             glob_x2.
              perform bmtab_getbyte_packbits tables bitmap_file
                                             USING ofs
                                             tif_stripofs_tab-ofs
                                             c_false
                                             glob_x3.
          ENDCASE.
          add 1 to col.
*         calculate 8 bit intensity value (0..255)
          intensity = ( 30 * glob_x1 + 59 * glob_x2 + 11 * glob_x3 )
             div 100.
          case tif_info-colormap_size.
            when 2.
              if intensity > 127. "white = 0
              else.               "black = 1
                curbyte = curbyte bit-or bitmask.
              endif.
              if bitmask = '01'. "rightmost bit
                perform bm_file_putbyte using curbyte.
                add 1 to row_bytes_written.
                bitmask = '80'. curbyte = '00'.
              else.
                bitmask = bitmask div 2.
              endif.
            when 256.
              curbyte = intensity.
              perform bm_file_putbyte using curbyte.
              add 1 to row_bytes_written.
          endcase.
        ENDWHILE.
        if not bitmask = '80'.
          perform bm_file_putbyte using curbyte.
          add 1 to row_bytes_written.
        endif.
        while row_bytes_written < otf_bminfo-bytes_per_row.
          perform bm_file_putbyte using '00'. "fill up to 4 byte border
          add 1 to row_bytes_written.
        endwhile.
      ENDDO.
    ENDLOOP.
  else.
*   24bit color->8bit color
    ofs = 0.
    do otf_bminfo-h_pix times.
      row_bytes_written = 0.
      do otf_bminfo-w_pix times.
        perform bm_file8bit_getbyte using ofs curbyte.
        add 1 to ofs.
        perform bm_file_putbyte using curbyte.
        add 1 to row_bytes_written.
      enddo.
      while row_bytes_written < otf_bminfo-bytes_per_row.
        perform bm_file_putbyte using '00'. "fill up to 4 byte border
        add 1 to row_bytes_written.
      endwhile.
    enddo.
  endif.

  WHEN C_TIFTYPE_COLORMAP.
*   16 or 256 entry RGB color map
*   ATTENTION: 4-bit pixels ARE packed, 2 pixels per byte!
*   loop over image data strips and fill pixel table
*   CAUTION: every strip contains TIF_INFO-ROWSPERSTRIP rows except
*   the last one which may contain fewer rows
    ROW = 0.
    LOOP AT TIF_STRIPOFS_TAB.
      OFS = TIF_STRIPOFS_TAB-OFS.
      DO TIF_INFO-MAXROW TIMES.
        ADD 1 TO ROW.
        CHECK ROW <= TIF_INFO-LENGTH.
        COL = 0. row_bytes_written = 0.
        WHILE COL < TIF_INFO-MAXCOL.
          CASE TIF_INFO-COMPRESSION.
            WHEN C_COMP_UNCOMP.
              perform bmptab_getbyte_ofs tables bitmap_file
                                         using ofs glob_x1.
            WHEN C_COMP_PACKBITS.
              IF OFS = TIF_STRIPOFS_TAB-OFS. "first byte in strip
                firstcol = c_true.
              else.
                firstcol = c_false.
              endif.
              perform bmtab_getbyte_packbits tables bitmap_file
                                             USING ofs
                                             tif_stripofs_tab-ofs
                                             firstcol
                                             glob_x1.
          ENDCASE.
          case tif_info-bitspersample_1.
            when 4. "2 pixels in one byte
              perform bm_file_putbyte using glob_x1.
              add 2 to col.
              add 1 to row_bytes_written.
            when 8. "1 pixel in one byte
              perform bm_file_putbyte using glob_x1.
              add 1 to col.
              add 1 to row_bytes_written.
          endcase.
        ENDWHILE.
        while row_bytes_written < otf_bminfo-bytes_per_row.
          perform bm_file_putbyte using '00'. "fill up to 4 byte border
          add 1 to row_bytes_written.
        endwhile.
      ENDDO.
    ENDLOOP.
ENDCASE.
perform bm_file_flush.
SY-SUBRC = 0.
ENDFORM.

* get single pixel value when data is encoded using packbits compression
* set SY-SUBRC
form bmtab_getbyte_packbits tables bitmap_file
                            USING ofs type i
                                  STRIPOFFSET type i
                                  FIRSTCOL type ty_boolean
                                  byte type x.
CONSTANTS:
      C_ST_ERROR VALUE '1',
      C_ST_START VALUE '2',
      C_ST_LIT   VALUE '3',
      C_ST_REP   VALUE '4'.
STATICS: EXITFLAG,
         PB_CUR_BYTE type x, PB_REP_BYTE type x,
         PB_REP_COUNT TYPE I, PB_LIT_COUNT TYPE I,
         PB_STATE VALUE '1'.

IF FIRSTCOL = C_TRUE.
  ofs = STRIPOFFSET.
  PB_STATE = C_ST_START.
ENDIF.
EXITFLAG = C_FALSE.
WHILE EXITFLAG = C_FALSE.
  CASE PB_STATE.
    WHEN C_ST_ERROR.
      EXIT.
    WHEN C_ST_START.
      perform bmptab_getbyte_ofs tables bitmap_file
                                 using ofs PB_CUR_BYTE.
      IF PB_CUR_BYTE = '80'.
*       state stays C_ST_START, skip byte
      ELSE.
        IF PB_CUR_BYTE > 127. "n between 81 and FF-> -128 .. -1
          PB_REP_COUNT = 256 - PB_CUR_BYTE + 1.
          PB_STATE = C_ST_REP.
          perform bmptab_getbyte_ofs tables bitmap_file
                                     using ofs PB_REP_BYTE.
        ELSE.                 "n between 00 and 7F-> 0 .. 127
          PB_LIT_COUNT = PB_CUR_BYTE + 1.
          PB_STATE = C_ST_LIT.
        ENDIF.
      ENDIF.
    WHEN C_ST_LIT.
      perform bmptab_getbyte_ofs tables bitmap_file
                                 using ofs PB_CUR_BYTE.
      BYTE = PB_CUR_BYTE.
      PB_LIT_COUNT = PB_LIT_COUNT - 1.
      IF PB_LIT_COUNT = 0. PB_STATE = C_ST_START. ENDIF.
      EXITFLAG = C_TRUE.
    WHEN C_ST_REP.
      BYTE = PB_REP_BYTE.
      PB_REP_COUNT = PB_REP_COUNT - 1.
      IF PB_REP_COUNT = 0. PB_STATE = C_ST_START. ENDIF.
      EXITFLAG = C_TRUE.
  ENDCASE.
ENDWHILE.
IF EXITFLAG = C_TRUE.
  SY-SUBRC = 0.
ELSE.
  SY-SUBRC = 1.
ENDIF.
ENDFORM.

* loop over tags in IFD and read data, set SY-SUBRC
* NEXTIFDOFS contains offset of next IFD (if one exists), else 0
FORM TIF_READ_IFD tables bitmap_file
                  USING VALUE(OFS) NEXTIFDOFS.
STATICS: NUMTAGS TYPE I.

perform bmptab_getword_ofs tables bitmap_file
                           using ofs numtags.
DO NUMTAGS TIMES.
  PERFORM TIF_READ_TAG tables bitmap_file
                       USING OFS.
  if sy-subrc <> 0.
    exit.
  endif.
  ADD 12 TO OFS.
ENDDO.
check sy-subrc = 0.
perform bmptab_getdword_ofs tables bitmap_file
                            using ofs nextifdofs.
SY-SUBRC = 0.
ENDFORM.

* read single TIFF tag at OFS, set SY-SUBRC
FORM TIF_READ_TAG tables bitmap_file
                  USING VALUE(OFS).
STATICS: TAGTYPE TYPE I,
         DATATYPE TYPE I,
         DATALEN TYPE I,
         SHORT_DATAOFS TYPE I,
         LONG_DATAOFS TYPE I.

perform bmptab_getword_ofs tables bitmap_file
                           using ofs tagtype.
perform bmptab_getword_ofs tables bitmap_file
                           using ofs datatype.
perform bmptab_getdword_ofs tables bitmap_file
                            using ofs datalen.
SHORT_DATAOFS = OFS.
perform bmptab_getdword_ofs tables bitmap_file
                            using ofs long_dataofs.
sy-subrc = 0.
CASE TAGTYPE.
  WHEN 256. "image width tag
    PERFORM TIF_IMAGEWIDTH_TAG tables bitmap_file
                               using DATATYPE DATALEN
                                     SHORT_DATAOFS LONG_DATAOFS.
  WHEN 257. "image length tag
    PERFORM TIF_IMAGELENGTH_TAG tables bitmap_file
                                using DATATYPE DATALEN
                                      SHORT_DATAOFS LONG_DATAOFS.
  WHEN 258. "bits per sample tag
    PERFORM TIF_BITSPERSAMPLE_TAG tables bitmap_file
                                  using DATATYPE DATALEN
                                        SHORT_DATAOFS LONG_DATAOFS.
  WHEN 259. "compression tag
    PERFORM TIF_COMPRESSION_TAG tables bitmap_file
                                using DATATYPE DATALEN
                                      SHORT_DATAOFS LONG_DATAOFS.
  WHEN 262. "photometric interpretation tag
    PERFORM TIF_PHOTOMETRIC_TAG tables bitmap_file
                                using DATATYPE DATALEN
                                      SHORT_DATAOFS LONG_DATAOFS.
  WHEN 266. "fillorder tag
    PERFORM TIF_FILLORDER_TAG tables bitmap_file
                              using DATATYPE DATALEN
                                    SHORT_DATAOFS LONG_DATAOFS.
  WHEN 273. "strip offset tag
    PERFORM TIF_STRIPOFFSET_TAG tables bitmap_file
                                using DATATYPE DATALEN
                                      SHORT_DATAOFS LONG_DATAOFS.
  WHEN 277. "samples per pixel tag
    PERFORM TIF_SAMPLESPERPIXEL_TAG tables bitmap_file
                                    using DATATYPE DATALEN
                                          SHORT_DATAOFS LONG_DATAOFS.
  WHEN 278. "rows per strip tag
    PERFORM TIF_ROWSPERSTRIP_TAG tables bitmap_file
                                    using DATATYPE DATALEN
                                          SHORT_DATAOFS LONG_DATAOFS.
  WHEN 279. "strip byte counts tag
    PERFORM TIF_STRIPBYTECOUNTS_TAG tables bitmap_file
                                    using DATATYPE DATALEN
                                          SHORT_DATAOFS LONG_DATAOFS.
  WHEN 280. "min sample value tag
    PERFORM TIF_MINSAMPLEVALUE_TAG tables bitmap_file
                                   using DATATYPE DATALEN
                                         SHORT_DATAOFS LONG_DATAOFS.
  WHEN 281. "max sample value tag
    PERFORM TIF_MAXSAMPLEVALUE_TAG tables bitmap_file
                                   using DATATYPE DATALEN
                                         SHORT_DATAOFS LONG_DATAOFS.

  WHEN 282. "x resolution tag
    PERFORM TIF_XRESOLUTION_TAG tables bitmap_file
                                using DATATYPE DATALEN
                                      SHORT_DATAOFS LONG_DATAOFS.
  WHEN 283. "y resolution tag
    PERFORM TIF_YRESOLUTION_TAG tables bitmap_file
                                using DATATYPE DATALEN
                                      SHORT_DATAOFS LONG_DATAOFS.
  WHEN 296. "resolution unit tag
    PERFORM TIF_RESUNIT_TAG tables bitmap_file
                                using DATATYPE DATALEN
                                      SHORT_DATAOFS LONG_DATAOFS.
  WHEN 320. "color map tag
    PERFORM TIF_COLORMAP_TAG tables bitmap_file
                                using DATATYPE DATALEN
                                      SHORT_DATAOFS LONG_DATAOFS.
  WHEN OTHERS.
*   unknown tag, ignore
ENDCASE.
case sy-subrc.
  when 0. "TIFF o.k.
  when 1. "TIFF format error
    MESSAGE E880 RAISING tifferr_invalid_format.
  when others.
endcase.
ENDFORM.

FORM TIF_IMAGEWIDTH_TAG tables bitmap_file
                        USING VALUE(DATATYPE) VALUE(DATALEN)
                              VALUE(SHORT_DATAOFS) VALUE(LONG_DATAOFS).
IF DATATYPE <> C_DTYPE_SHORT AND DATATYPE <> C_DTYPE_LONG.
  SY-SUBRC = 1. EXIT.
ENDIF.
IF DATALEN <> 1.
  SY-SUBRC = 1. EXIT.
ENDIF.
IF DATATYPE = C_DTYPE_SHORT.
  perform bmptab_getword_ofs tables bitmap_file
                             using short_dataofs tif_info-width.
ELSE.
  perform bmptab_getdword_ofs tables bitmap_file
                              using short_dataofs tif_info-width.
ENDIF.
SY-SUBRC = 0.
ENDFORM.

* decode image length tag, set SY-SUBRC
FORM TIF_IMAGELENGTH_TAG tables bitmap_file
                         USING VALUE(DATATYPE) VALUE(DATALEN)
                            VALUE(SHORT_DATAOFS) VALUE(LONG_DATAOFS).
IF DATATYPE <> C_DTYPE_SHORT AND DATATYPE <> C_DTYPE_LONG.
  SY-SUBRC = 1. EXIT.
ENDIF.
IF DATALEN <> 1.
  SY-SUBRC = 1. EXIT.
ENDIF.
IF DATATYPE = C_DTYPE_SHORT.
  perform bmptab_getword_ofs tables bitmap_file
                             using short_dataofs tif_info-length.
ELSE.
  perform bmptab_getdword_ofs tables bitmap_file
                              using short_dataofs tif_info-length.
ENDIF.
SY-SUBRC = 0.
ENDFORM.

* decode bits per sample tag, set SY-SUBRC
FORM TIF_BITSPERSAMPLE_TAG tables bitmap_file
                           USING VALUE(DATATYPE) VALUE(DATALEN)
                            VALUE(SHORT_DATAOFS) VALUE(LONG_DATAOFS).
IF DATATYPE <> C_DTYPE_SHORT.
  SY-SUBRC = 1. EXIT.
ENDIF.
IF DATALEN <> 1 AND DATALEN <> 3.
  SY-SUBRC = 1. EXIT.
ENDIF.
TIF_INFO-BITSPERSAMPLEPLANES = DATALEN.
IF TIF_INFO-BITSPERSAMPLEPLANES = 1.
  perform bmptab_getword_ofs tables bitmap_file
                             using short_dataofs
                                   TIF_INFO-BITSPERSAMPLE_1.
ELSE.
  perform bmptab_getword_ofs tables bitmap_file
                             using long_dataofs
                                   TIF_INFO-BITSPERSAMPLE_1.
  perform bmptab_getword_ofs tables bitmap_file
                             using long_dataofs
                                   TIF_INFO-BITSPERSAMPLE_2.
  perform bmptab_getword_ofs tables bitmap_file
                             using long_dataofs
                                   TIF_INFO-BITSPERSAMPLE_3.
ENDIF.
SY-SUBRC = 0.
ENDFORM.

* decode compression tag, set SY-SUBRC
FORM TIF_COMPRESSION_TAG tables bitmap_file
                         USING VALUE(DATATYPE) VALUE(DATALEN)
                               VALUE(SHORT_DATAOFS) VALUE(LONG_DATAOFS).
IF DATATYPE <> C_DTYPE_SHORT.
  SY-SUBRC = 1. EXIT.
ENDIF.
IF DATALEN <> 1.
  SY-SUBRC = 1. EXIT.
ENDIF.
perform bmptab_getword_ofs tables bitmap_file
                           using short_dataofs tif_info-compression.
SY-SUBRC = 0.
ENDFORM.

* decode photometric interpretation tag, set SY-SUBRC
FORM TIF_PHOTOMETRIC_TAG tables bitmap_file
                         USING VALUE(DATATYPE) VALUE(DATALEN)
                               VALUE(SHORT_DATAOFS) VALUE(LONG_DATAOFS).
IF DATATYPE <> C_DTYPE_SHORT.
  SY-SUBRC = 1. EXIT.
ENDIF.
IF DATALEN <> 1.
  SY-SUBRC = 1. EXIT.
ENDIF.
perform bmptab_getword_ofs tables bitmap_file
                           using short_dataofs tif_info-photometric.
SY-SUBRC = 0.
ENDFORM.

* decode fillorder tag, set SY-SUBRC
FORM TIF_FILLORDER_TAG tables bitmap_file
                       USING VALUE(DATATYPE) VALUE(DATALEN)
                             VALUE(SHORT_DATAOFS) VALUE(LONG_DATAOFS).
IF DATATYPE <> C_DTYPE_SHORT.
  SY-SUBRC = 1. EXIT.
ENDIF.
IF DATALEN <> 1.
  SY-SUBRC = 1. EXIT.
ENDIF.
perform bmptab_getword_ofs tables bitmap_file
                           using short_dataofs tif_info-fillorder.
SY-SUBRC = 0.
ENDFORM.

* decode strip offset tag, set SY-SUBRC
FORM TIF_STRIPOFFSET_TAG tables bitmap_file
                         USING VALUE(DATATYPE) VALUE(DATALEN)
                               VALUE(SHORT_DATAOFS) VALUE(LONG_DATAOFS).
IF DATATYPE <> C_DTYPE_SHORT AND DATATYPE <> C_DTYPE_LONG.
  SY-SUBRC = 1. EXIT.
ENDIF.
REFRESH TIF_STRIPOFS_TAB.
IF DATALEN = 1. "single strip of image data
  TIF_INFO-NUMBER_STRIPS = 1.
  IF DATATYPE = C_DTYPE_SHORT.
    perform bmptab_getword_ofs tables bitmap_file
                               using short_dataofs
                                     TIF_STRIPOFS_TAB-OFS.
  ELSE.
    perform bmptab_getdword_ofs tables bitmap_file
                                using short_dataofs
                                      TIF_STRIPOFS_TAB-OFS.
  ENDIF.
  APPEND TIF_STRIPOFS_TAB.
ELSE.           "multiple image data strips
  TIF_INFO-NUMBER_STRIPS = DATALEN.
  DO TIF_INFO-NUMBER_STRIPS TIMES.
    perform bmptab_getdword_ofs tables bitmap_file
                                using long_dataofs
                                      TIF_STRIPOFS_TAB-OFS.
    APPEND TIF_STRIPOFS_TAB.
  ENDDO.
ENDIF.
SY-SUBRC = 0.
ENDFORM.

* decode samples per pixel tag, set SY-SUBRC
FORM TIF_SAMPLESPERPIXEL_TAG tables bitmap_file
                             USING VALUE(DATATYPE) VALUE(DATALEN)
                               VALUE(SHORT_DATAOFS) VALUE(LONG_DATAOFS).
IF DATATYPE <> C_DTYPE_SHORT.
  SY-SUBRC = 1. EXIT.
ENDIF.
IF DATALEN <> 1.
  SY-SUBRC = 1. EXIT.
ENDIF.
perform bmptab_getword_ofs tables bitmap_file
                           using short_dataofs
                                 TIF_INFO-SAMPLESPERPIX.
SY-SUBRC = 0.
ENDFORM.

* decode rows per strip tag, set SY-SUBRC
FORM TIF_ROWSPERSTRIP_TAG tables bitmap_file
                          USING VALUE(DATATYPE) VALUE(DATALEN)
                               VALUE(SHORT_DATAOFS) VALUE(LONG_DATAOFS).
IF DATATYPE <> C_DTYPE_SHORT AND DATATYPE <> C_DTYPE_LONG.
  SY-SUBRC = 1. EXIT.
ENDIF.
IF DATALEN <> 1.
  SY-SUBRC = 1. EXIT.
ENDIF.
IF DATATYPE = C_DTYPE_SHORT.
  perform bmptab_getword_ofs tables bitmap_file
                             using short_dataofs tif_info-rowsperstrip.
ELSE.
  perform bmptab_getlong_ofs tables bitmap_file
                             using short_dataofs tif_info-rowsperstrip.
* this may return -1, since if there's only one strip, all rows of
* the image are in that strip and the default for this field is then
* 2^32-1 = 0xffffffff which is returned as -1 by T_GET_ULONG_FROM_4
ENDIF.
SY-SUBRC = 0.
ENDFORM.

* decode strip byte counts tag, set SY-SUBRC
FORM TIF_STRIPBYTECOUNTS_TAG tables bitmap_file
                             USING VALUE(DATATYPE) VALUE(DATALEN)
                               VALUE(SHORT_DATAOFS) VALUE(LONG_DATAOFS).
STATICS: TABIX LIKE SY-TABIX.

IF DATATYPE <> C_DTYPE_SHORT AND DATATYPE <> C_DTYPE_LONG.
  SY-SUBRC = 1. EXIT.
ENDIF.
CASE DATALEN.
  WHEN 1. "only one strip of image data
    READ TABLE TIF_STRIPOFS_TAB INDEX 1.
    CHECK SY-SUBRC = 0.
    IF DATATYPE = C_DTYPE_SHORT.
      perform bmptab_getword_ofs tables bitmap_file
                                 using short_dataofs
                                       TIF_STRIPOFS_TAB-COUNT.
    ELSE.
      perform bmptab_getdword_ofs tables bitmap_file
                                  using short_dataofs
                                        TIF_STRIPOFS_TAB-COUNT.
    ENDIF.
    MODIFY TIF_STRIPOFS_TAB INDEX 1.
  WHEN 2. "only 2 strips of image data
    IF DATATYPE = C_DTYPE_SHORT. "2 SHORT fit in tag area
      READ TABLE TIF_STRIPOFS_TAB INDEX 1.
      CHECK SY-SUBRC = 0.
      perform bmptab_getword_ofs tables bitmap_file
                                 using short_dataofs
                                       TIF_STRIPOFS_TAB-COUNT.
      MODIFY TIF_STRIPOFS_TAB INDEX 1.
      READ TABLE TIF_STRIPOFS_TAB INDEX 2.
      CHECK SY-SUBRC = 0.
      perform bmptab_getword_ofs tables bitmap_file
                                 using short_dataofs
                                       TIF_STRIPOFS_TAB-COUNT.
      MODIFY TIF_STRIPOFS_TAB INDEX 2.
    ELSE.                        "2 LONG don't fit in tag area
      READ TABLE TIF_STRIPOFS_TAB INDEX 1.
      CHECK SY-SUBRC = 0.
      perform bmptab_getdword_ofs tables bitmap_file
                                  using long_dataofs
                                        TIF_STRIPOFS_TAB-COUNT.
      MODIFY TIF_STRIPOFS_TAB INDEX 1.
      READ TABLE TIF_STRIPOFS_TAB INDEX 2.
      CHECK SY-SUBRC = 0.
      perform bmptab_getdword_ofs tables bitmap_file
                                  using long_dataofs
                                        TIF_STRIPOFS_TAB-COUNT.
      MODIFY TIF_STRIPOFS_TAB INDEX 2.
    ENDIF.
  WHEN OTHERS. "more than 2 strips of image data
    TABIX = 1.
    DO DATALEN TIMES.
      READ TABLE TIF_STRIPOFS_TAB INDEX TABIX.
      CHECK SY-SUBRC = 0.
      IF DATATYPE = C_DTYPE_SHORT.
        perform bmptab_getword_ofs tables bitmap_file
                                   using short_dataofs
                                         TIF_STRIPOFS_TAB-COUNT.
      ELSE.
        perform bmptab_getdword_ofs tables bitmap_file
                                    using long_dataofs
                                          TIF_STRIPOFS_TAB-COUNT.
      ENDIF.
      MODIFY TIF_STRIPOFS_TAB INDEX TABIX.
      ADD 1 TO TABIX.
    ENDDO.
ENDCASE.
CHECK SY-SUBRC = 0.
ENDFORM.

* decode minimum sample value tag, set SY-SUBRC
FORM TIF_MINSAMPLEVALUE_TAG tables bitmap_file
                            USING VALUE(DATATYPE) VALUE(DATALEN)
                               VALUE(SHORT_DATAOFS) VALUE(LONG_DATAOFS).
IF DATATYPE <> C_DTYPE_SHORT.
  SY-SUBRC = 1. EXIT.
ENDIF.
IF DATALEN <> 1.
  SY-SUBRC = 1. EXIT.
ENDIF.
perform bmptab_getword_ofs tables bitmap_file
                           using short_dataofs tif_info-minsample.
SY-SUBRC = 0.
ENDFORM.

* decode maximum sample value tag, set SY-SUBRC
FORM TIF_MAXSAMPLEVALUE_TAG tables bitmap_file
                            USING VALUE(DATATYPE) VALUE(DATALEN)
                               VALUE(SHORT_DATAOFS) VALUE(LONG_DATAOFS).
IF DATATYPE <> C_DTYPE_SHORT.
  SY-SUBRC = 1. EXIT.
ENDIF.
IF DATALEN <> 1.
  SY-SUBRC = 1. EXIT.
ENDIF.
perform bmptab_getword_ofs tables bitmap_file
                           using short_dataofs tif_info-maxsample.
SY-SUBRC = 0.
ENDFORM.

* decode x resolution value tag, set SY-SUBRC
FORM TIF_XRESOLUTION_TAG tables bitmap_file
                         USING VALUE(DATATYPE) VALUE(DATALEN)
                               VALUE(SHORT_DATAOFS) VALUE(LONG_DATAOFS).
IF DATATYPE <> C_DTYPE_RATIONAL.
  SY-SUBRC = 1. EXIT.
ENDIF.
IF DATALEN <> 1.
  SY-SUBRC = 1. EXIT.
ENDIF.
perform bmptab_getdword_ofs tables bitmap_file
                            using long_dataofs tif_info-xres_n.
perform bmptab_getdword_ofs tables bitmap_file
                            using long_dataofs tif_info-xres_d.
CHECK SY-SUBRC = 0.
SY-SUBRC = 0.
ENDFORM.

* decode y resolution value tag, set SY-SUBRC
FORM TIF_YRESOLUTION_TAG tables bitmap_file
                         USING VALUE(DATATYPE) VALUE(DATALEN)
                               VALUE(SHORT_DATAOFS) VALUE(LONG_DATAOFS).
IF DATATYPE <> C_DTYPE_RATIONAL.
  SY-SUBRC = 1. EXIT.
ENDIF.
IF DATALEN <> 1.
  SY-SUBRC = 1. EXIT.
ENDIF.
perform bmptab_getdword_ofs tables bitmap_file
                            using long_dataofs tif_info-yres_n.
perform bmptab_getdword_ofs tables bitmap_file
                            using long_dataofs tif_info-yres_d.
SY-SUBRC = 0.
ENDFORM.

* decode resolution unit tag, set SY-SUBRC
FORM TIF_RESUNIT_TAG tables bitmap_file
                     USING VALUE(DATATYPE) VALUE(DATALEN)
                           VALUE(SHORT_DATAOFS) VALUE(LONG_DATAOFS).
IF DATATYPE <> C_DTYPE_SHORT.
  SY-SUBRC = 1. EXIT.
ENDIF.
IF DATALEN <> 1.
  SY-SUBRC = 1. EXIT.
ENDIF.
perform bmptab_getword_ofs tables bitmap_file
                           using short_dataofs tif_info-resunit.
SY-SUBRC = 0.
ENDFORM.

* decode color map tag, set SY-SUBRC
FORM TIF_COLORMAP_TAG tables bitmap_file
                      USING VALUE(DATATYPE) VALUE(DATALEN)
                            VALUE(SHORT_DATAOFS) VALUE(LONG_DATAOFS).
STATICS: REDOFS TYPE I,
         GREENOFS TYPE I,
         BLUEOFS TYPE I.

IF DATATYPE <> C_DTYPE_SHORT.
  SY-SUBRC = 1. EXIT.
ENDIF.
REFRESH TIF_COLOR_TAB.
TIF_INFO-COLORMAP_SIZE = DATALEN DIV 3.
REDOFS = LONG_DATAOFS.
GREENOFS = REDOFS + 2 * TIF_INFO-COLORMAP_SIZE.
BLUEOFS = GREENOFS + 2 * TIF_INFO-COLORMAP_SIZE.
DO TIF_INFO-COLORMAP_SIZE TIMES.
  CLEAR TIF_COLOR_TAB. "set intensities to 0
  perform bmptab_getword_ofs tables bitmap_file
                             using redofs tif_color_tab-r.
  perform bmptab_getword_ofs tables bitmap_file
                             using greenofs tif_color_tab-g.
  perform bmptab_getword_ofs tables bitmap_file
                             using blueofs tif_color_tab-b.
  APPEND TIF_COLOR_TAB.
ENDDO.
SY-SUBRC = 0.
ENDFORM.

*********************************************************************
* *.BMP to ITF conversion, part 2
* convert bitmap data from BM_FILE into ITF format
* use info from OTF_BMINFO struct
* ITF_BITMAPTYPE controls a possible conversion from COL->MON
* value (*) indicates -> BCOL for 16/256 color BMPs, BMON for 2 color
*********************************************************************
form fill_itflines_from_bmfile tables lines structure tline
                               using value(itf_bitmaptype).
  statics: numc5(5) type n,
           numc3(3) type n,
           dpi_char(3) type n,
           cur_lineofs type i,
           red type x,
           green type x,
           blue type x,
           byte type x,
           int type i,
           bm_fileofs type i,
           convert_col_to_mon type ty_boolean,
           final_bytes_per_row type i,
           final_num_databytes type i.
  statics: begin of coltab occurs 100,
    r type x,
    g type x,
    b type x,
    is_white type ty_boolean,
        end   of coltab.

  refresh lines. clear lines.
  refresh coltab.
* /:  HEX TYPE BCOL HEIGHT 500 TW RESI
  lines-tdformat = c_itf_format_cmd.
  lines-tdline   = '$ $ $ $ $ $ %'.
  replace '$' with c_itf_hex_hex into lines-tdline.
  replace '$' with c_itf_hex_type into lines-tdline.
  case itf_bitmaptype.
    when c_itf_hex_bmon.               "-> output should be BMON
      convert_col_to_mon = c_true.
    when c_itf_hex_bcol.               "-> output should be BCOL
      convert_col_to_mon = c_false.
    when others.                       "*, it depends
      if otf_bminfo-coltabsize = 2.
        convert_col_to_mon = c_true.
      else.
        convert_col_to_mon = c_false.
      endif.
  endcase.
  if convert_col_to_mon = c_true.
    otf_bminfo-bmtype = c_itf_hex_bmon.
  else.
    otf_bminfo-bmtype = c_itf_hex_bcol.
  endif.
  replace '$' with otf_bminfo-bmtype into lines-tdline.
  replace '$' with c_itf_hex_height into lines-tdline.
  if otf_bminfo-autoheight = c_true.
    numc5 = otf_bminfo-res_h_tw.
    replace '$' with numc5 into lines-tdline.
  else.
    replace '$' with '0' into lines-tdline.
  endif.
  replace '$' with c_itf_hex_twip into lines-tdline.
  if otf_bminfo-new_rd_format = c_true.
    replace '%' with c_itf_hex_resi into lines-tdline.
  else.
    replace '%' with space into lines-tdline.
  endif.
  condense lines-tdline. append lines.
* /* author comment line
  lines-tdformat = c_itf_format_cmnt.
  lines-tdline =
        'CREATOR: SAPSCRIPT_CONVERT_BITMAP DATE $ TIME & USER %'.
  replace '$' with sy-datum into lines-tdline.
  replace '&' with sy-uzeit into lines-tdline.
  replace '%' with sy-uname into lines-tdline.
  append lines.
* BMP format comment line
  lines-tdformat = c_itf_format_cmnt.
  lines-tdline =
                'BMP file converted to %, resolution % dpi'. "#EC NOTEXT
  replace '%' with otf_bminfo-bmtype into lines-tdline.
  dpi_char = otf_bminfo-dpi.
  replace '%' with dpi_char into lines-tdline. condense lines-tdline.
  append lines.
  lines-tdline =
                           'Image width: %, Image height: %'."#EC NOTEXT
  numc5 = otf_bminfo-w_pix.
  replace '%' with numc5 into lines-tdline.
  numc5 = otf_bminfo-h_pix.
  replace '%' with numc5 into lines-tdline.
  condense lines-tdline. append lines.
  lines-tdline =
                   'Bits per pixel: %, Size of color map: %'."#EC NOTEXT
  if convert_col_to_mon = c_true.
    numc3 = 1.
  else.
    numc3 = otf_bminfo-bitsperpix.
  endif.
  replace '%' with numc3 into lines-tdline.
  if convert_col_to_mon = c_true.
    numc3 = 0.
  else.
    numc3 = otf_bminfo-coltabsize.
  endif.
  replace '%' with numc3 into lines-tdline.
  condense lines-tdline. append lines.
  lines-tdformat = c_itf_format_cmnt.
  lines-tdline   = 'COMMENT: BEGIN OF BINARY FILE DATA'.
  append lines.
* OTF header bytes
  cur_lineofs = 0.
  lines-tdformat = c_itf_format_datl.
  perform lt_write_otf_imgheader tables lines
                                 using cur_lineofs
                                       convert_col_to_mon
                                       final_num_databytes
                                       final_bytes_per_row.
* OTF COLOR TABLE
  bm_fileofs = 0.
  statics: intensity type i.
  do otf_bminfo-coltabsize times.
    perform bm_file_getbyte using bm_fileofs red.
    add 1 to bm_fileofs.
    perform bm_file_getbyte using bm_fileofs green.
    add 1 to bm_fileofs.
    perform bm_file_getbyte using bm_fileofs blue.
    add 1 to bm_fileofs.
    if convert_col_to_mon = c_false.
      int = red * 256.
      perform lt_put_2byte_int tables lines
                               using cur_lineofs int.
      int = green * 256.
      perform lt_put_2byte_int tables lines
                               using cur_lineofs int.
      int = blue * 256.
      perform lt_put_2byte_int tables lines
                               using cur_lineofs int.
    else.
      coltab-r = red.
      coltab-g = green.
      coltab-b = blue.
      int = ( 30 * coltab-r + 59 * coltab-g + 11 * coltab-b ) div 100.
      if int > 127.
        coltab-is_white = c_true.
      else.
        coltab-is_white = c_false.
      endif.
      append coltab.
    endif.
  enddo.
* OTF bitmap data
  statics: bufbyte type x,
           nibble1 type x,
           nibble2 type x,
           src_bytes_consumed type i,
           dst_bytes_written type i,
           pixels_read_in_row type i,
           missing_bytes type i.
  if convert_col_to_mon = c_false or otf_bminfo-coltabsize = 2.
    do otf_bminfo-h_pix times.
      do otf_bminfo-bytes_per_row times.
        perform bm_file_getbyte using bm_fileofs byte.
        add 1 to bm_fileofs.
        perform lt_put_byte tables lines
                            using cur_lineofs byte.
      enddo.
    enddo.
  else.
    do otf_bminfo-h_pix times.
      perform bitbuf using c_bitbuf_clear
                           c_bitbuf_whitepix
                           bufbyte.
      src_bytes_consumed = dst_bytes_written = 0.
      pixels_read_in_row = 0.
      while pixels_read_in_row < otf_bminfo-w_pix.
        perform bm_file_getbyte using bm_fileofs byte.
        add 1 to bm_fileofs.
        add 1 to src_bytes_consumed.
        case otf_bminfo-bitsperpix.
          when 4.                      "one byte contains 2 pixel
            nibble1 = byte div 16.     "upper nibble
            nibble2 = byte mod 16.     "lower nibble
            byte = 1 + nibble1.
            read table coltab index byte.
            if coltab-is_white = c_true.
              perform bitbuf using c_bitbuf_push
                                   c_bitbuf_whitepix
                                   bufbyte.
            else.
              perform bitbuf using c_bitbuf_push
                                   c_bitbuf_blackpix
                                   bufbyte.
            endif.
            byte = 1 + nibble2.
            read table coltab index byte.
            if coltab-is_white = c_true.
              perform bitbuf using c_bitbuf_push
                                   c_bitbuf_whitepix
                                   bufbyte.
            else.
              perform bitbuf using c_bitbuf_push
                                   c_bitbuf_blackpix
                                   bufbyte.
            endif.
            add 2 to pixels_read_in_row.
          when 8.                      "one byte contains 1 pixel
            add 1 to byte.
            read table coltab index byte.
            if coltab-is_white = c_true.
              perform bitbuf using c_bitbuf_push
                                   c_bitbuf_whitepix
                                   bufbyte.
            else.
              perform bitbuf using c_bitbuf_push
                                   c_bitbuf_blackpix
                                   bufbyte.
            endif.
            add 1 to pixels_read_in_row.
        endcase.
        if sy-subrc = 1 or pixels_read_in_row >= otf_bminfo-w_pix.
          perform lt_put_byte tables lines
                               using cur_lineofs bufbyte.
          add 1 to dst_bytes_written.
          perform bitbuf using c_bitbuf_clear
                               c_bitbuf_whitepix
                               bufbyte.
        endif.
      endwhile.
*   consume remaining color bitmap input bytes
      while src_bytes_consumed < otf_bminfo-bytes_per_row.
        perform bm_file_getbyte using bm_fileofs byte.
        add 1 to bm_fileofs.
        add 1 to src_bytes_consumed.
      endwhile.
*   write remaining monochrome bitmap output bytes (4-byte padding)
      while dst_bytes_written < final_bytes_per_row.
        perform lt_put_byte tables lines
                             using cur_lineofs c_bitbuf_whitepix.
        add 1 to dst_bytes_written.
      endwhile.
    enddo.
  endif.
  perform lt_flush tables lines
                   using  cur_lineofs.
* end hex command
  lines-tdformat = c_itf_format_cmnt.
  lines-tdline   = 'COMMENT: END OF BINARY FILE DATA'.
  append lines.
  lines-tdformat = c_itf_format_cmd.
  lines-tdline   = c_itf_hex_endhex.
  append lines.
endform.

* write OTF data for image: "OTFbitma" + control bytes to LINES
* using bitmap info from OTF_BMINFO
* ATTENTION: if CONVERT_COL_2_MON is set, some entries in OTF_BMINFO
*            have to be changed
form lt_write_otf_imgheader tables lines structure tline
                           using  cur_lineofs type i
                                  value(convert_col_2_mon)
                                  final_numdatabytes
                                  final_bytes_per_row.
  statics: mod4 type i,
           mod8 type i.

  lines-tdline = c_otf_rd_otfbitma.
  cur_lineofs = cur_lineofs + strlen( c_otf_rd_otfbitma ).
  if otf_bminfo-new_rd_format = c_true.  "new RD formats I,J
* new format: 4* FF, 4 parameter bytes,
* not implemented
  endif.
  perform lt_put_4byte_int tables lines
                           using cur_lineofs otf_bminfo-w_tw.
  perform lt_put_4byte_int tables lines
                           using cur_lineofs otf_bminfo-h_tw.
  perform lt_put_4byte_int tables lines
                           using cur_lineofs otf_bminfo-w_pix.
  perform lt_put_4byte_int tables lines
                           using cur_lineofs otf_bminfo-h_pix.
  perform lt_put_2byte_int tables lines
                           using cur_lineofs otf_bminfo-dpi.
  if convert_col_2_mon = c_true.
    perform lt_put_2byte_int tables lines
                             using cur_lineofs 1."1 bits per pixel
    perform lt_put_2byte_int tables lines
                             using cur_lineofs 0. "no color map
    final_bytes_per_row = otf_bminfo-w_pix div 8.
    mod8 = otf_bminfo-w_pix mod 8.
    if mod8 > 0.
      add 1 to final_bytes_per_row.
    endif.
    mod4 = final_bytes_per_row mod 4.
    if mod4 > 0.
      final_bytes_per_row = final_bytes_per_row + ( 4 - mod4 ).
    endif.
    final_numdatabytes = final_bytes_per_row * otf_bminfo-h_pix.
    perform lt_put_4byte_int tables lines
                             using cur_lineofs final_numdatabytes.
  else.
    perform lt_put_2byte_int tables lines
                             using cur_lineofs otf_bminfo-bitsperpix.
    perform lt_put_2byte_int tables lines
                             using cur_lineofs otf_bminfo-coltabsize.
    perform lt_put_4byte_int tables lines
                             using cur_lineofs otf_bminfo-numdatabytes.
    final_bytes_per_row = otf_bminfo-bytes_per_row.
    final_numdatabytes = otf_bminfo-numdatabytes.
  endif.
  if otf_bminfo-new_rd_format = c_true.  "new RD formats I,J
* 90 bytes image identifier
* not implemented
  endif.
endform.

* bit buffer for collecting 8 bits into a byte
form bitbuf using value(function) type c
                  value(bit) type x
                  byte type x.
  statics: factor type i,
           curbyte type x.

  case function.
    when c_bitbuf_clear.
      curbyte = 0. factor = 256. sy-subrc = 0.
    when c_bitbuf_push.
      if bit > 0.
        bit = c_bitbuf_blackpix.
      else.
        bit = c_bitbuf_whitepix.
      endif.
      factor = factor div 2.
      curbyte = curbyte + factor * bit.
      byte = curbyte.
      if factor = 1.
        sy-subrc = 1.
      else.
        sy-subrc = 0.
      endif.
  endcase.
endform.

* write OTF data for image: "OTFbitma" + control bytes to BDSTAB
* using bitmap info from OTF_BMINFO
* ATTENTION: if CONVERT_COL2_MON is set, some entries in OTF_BMINFO
*            have to be changed
form bds_write_otf_imgheader tables bdstab type sbdst_content
                             using value(convert_col_2_mon)
                                   value(resident)
                                   value(compress_bitmap)
                                   final_bytes_per_row type i
                                   final_bytes_per_row_act type i
                                   final_numdatabytes type i.
statics: mod4 type i,
         mod8 type i,
         magic like c_otf_rd_otfbitma,
         x type x.

magic = c_otf_rd_otfbitma.
do 8 times.
  x = magic(2).
  perform bdstab_putbyte tables bdstab
                         using x.
  shift magic by 2 places.
enddo.
otf_bminfo-new_rd_format = c_true.  "new RD formats I,J
* new format: 4* FF, 4 parameter bytes,
do 4 times.
  perform bdstab_putbyte tables bdstab
                         using c_otf_rd_ff.
enddo.
if convert_col_2_mon = c_true.
  perform bdstab_putbyte tables bdstab using c_otf_rd_formatid_bmon.
else.
  perform bdstab_putbyte tables bdstab using c_otf_rd_formatid_bcol.
endif.
perform bdstab_putbyte tables bdstab using c_otf_rd_subformatid_bds.
* format parameter 1: LO nibble-> resident yes/no
*                     HI nibble-> compression
if resident = c_true.
  otf_bminfo-is_resident = c_true.
  x = c_otf_rd_formatpar1_resi.
else.
  otf_bminfo-is_resident = c_false.
  x = c_otf_rd_formatpar1_nonresi.
endif.
if compress_bitmap = 'X'.
  x = x + c_otf_rd_formatpar1_hi_runl.
else.
  x = x + c_otf_rd_formatpar1_hi_nocomp.
endif.
perform bdstab_putbyte tables bdstab using x. "format parameter 1
perform bdstab_putbyte tables bdstab using
                                     c_otf_rd_formatpar2_none.
perform bdstab_put_4byte_int tables bdstab
                             using otf_bminfo-w_tw.
perform bdstab_put_4byte_int tables bdstab
                             using otf_bminfo-h_tw.
perform bdstab_put_4byte_int tables bdstab
                             using otf_bminfo-w_pix.
perform bdstab_put_4byte_int tables bdstab
                             using otf_bminfo-h_pix.
perform bdstab_put_2byte_int tables bdstab
                             using otf_bminfo-dpi.
if convert_col_2_mon = c_true.
  perform bdstab_put_2byte_int tables bdstab
                               using 1.  "1 bits per pixel
  perform bdstab_put_2byte_int tables bdstab
                               using 0.  "no color map
  final_bytes_per_row = otf_bminfo-w_pix div 8.
  mod8 = otf_bminfo-w_pix mod 8.
  if mod8 > 0.
    add 1 to final_bytes_per_row.
  endif.
  final_bytes_per_row_act = final_bytes_per_row.
  mod4 = final_bytes_per_row mod 4.
  if mod4 > 0.
    final_bytes_per_row = final_bytes_per_row + ( 4 - mod4 ).
  endif.
  final_numdatabytes = final_bytes_per_row * otf_bminfo-h_pix.
  perform bdstab_put_4byte_int tables bdstab
                             using final_numdatabytes.
else.
  perform bdstab_put_2byte_int tables bdstab
                               using otf_bminfo-bitsperpix.
  perform bdstab_put_2byte_int tables bdstab
                               using otf_bminfo-coltabsize.
  perform bdstab_put_4byte_int tables bdstab
                               using otf_bminfo-numdatabytes.
  final_bytes_per_row = otf_bminfo-bytes_per_row.
  final_bytes_per_row_act = otf_bminfo-bytes_per_row_act.
  final_numdatabytes = otf_bminfo-numdatabytes.
endif.
if otf_bminfo-new_rd_format = c_true.  "new RD formats I,J
  do 90 times.
    perform bdstab_putbyte tables bdstab using c_otf_rd_ff.
  enddo.
endif.
endform.

* fill BDS content table with OTF data for image stored in
* BMFILE, OTF_BMINFO
form fill_bds_content_from_bminfo tables bdstab type sbdst_content
                                  using  value(color)
                                         value(resident)
                                         value(compress_bitmap)
                                         bds_bytecount.
data: intensity type i,
      red type x,
      green type x,
      blue type x,
      byte type x,
      int type i,
      bm_fileofs type i,
      convert_col_to_mon type ty_boolean,
      final_bytes_per_row type i,
      final_bytes_per_row_act type i,
      final_numdatabytes type i.
data: begin of coltab occurs 100,
  r type x,
  g type x,
  b type x,
  is_white type ty_boolean,
      end   of coltab.

refresh coltab.
if color = c_true.
  convert_col_to_mon = c_false.
*  compress_bitmap = space.
else.
  convert_col_to_mon = c_true.
endif.
perform bdstab_init tables bdstab.
perform bds_write_otf_imgheader tables bdstab
                                using convert_col_to_mon
                                      resident
                                      compress_bitmap
                                      final_bytes_per_row
                                      final_bytes_per_row_act
                                      final_numdatabytes.
bm_fileofs = 0.
* color table
do otf_bminfo-coltabsize times.
  perform bm_file_getbyte using bm_fileofs red.
  add 1 to bm_fileofs.
  perform bm_file_getbyte using bm_fileofs green.
  add 1 to bm_fileofs.
  perform bm_file_getbyte using bm_fileofs blue.
  add 1 to bm_fileofs.
  if convert_col_to_mon = c_false.
    int = red * 256.
    perform bdstab_put_2byte_int tables bdstab using int.
    int = green * 256.
    perform bdstab_put_2byte_int tables bdstab using int.
    int = blue * 256.
    perform bdstab_put_2byte_int tables bdstab using int.
  else.
    coltab-r = red.
    coltab-g = green.
    coltab-b = blue.
    int = ( 30 * coltab-r + 59 * coltab-g + 11 * coltab-b ) div 100.
    if int > 127.
      coltab-is_white = c_true.
    else.
      coltab-is_white = c_false.
    endif.
    append coltab.
  endif.
enddo.
* bitmap data
statics: bufbyte type x,
         nibble1 type x,
         nibble2 type x,
         src_bytes_consumed type i,
         dst_bytes_written type i,
         pixels_read_in_row type i,
         missing_bytes type i,
         coltabix like sy-tabix,
         comp_linebytes_in type i,
         comp_linebytes_out type i,
         comp_totalbytes_out type i,
         bdstab_totalbytesofs type i,
         bdstab_bitmapdataofs type i,
         lastline type ty_boolean,
         l_ofs type i,
         tabixn like sy-tabix,
         tabixo like sy-tabix.
statics: begin of linebuf occurs 10,
        x type x,
         end   of linebuf.
tabixn =  0.
tabixo = 9999.
comp_totalbytes_out = 0.
bdstab_totalbytesofs = 38. "offset of TOTALBYTES in RD cmd
bdstab_bitmapdataofs = bdstab_totalbytesofs + 4 + 90.
if convert_col_to_mon = c_false or otf_bminfo-coltabsize = 2.
  if compress_bitmap = 'X'.
    do otf_bminfo-h_pix times.
      perform linebuf_init tables linebuf.
      if sy-index < otf_bminfo-h_pix.
        lastline = c_false.
      else.
        lastline = c_true.
      endif.
      do otf_bminfo-bytes_per_row times.
        perform bm_file_getbyte using bm_fileofs byte.
        add 1 to bm_fileofs.
        perform linebuf_putbyte tables linebuf using byte.
      enddo.
*     run-length compress linebuf:
*     we do NOT include the 4 byte padding bytes at end of each line!
*     so we read only the actual bytes from buffer, not the filled bytes
      comp_linebytes_in = final_bytes_per_row_act.
      perform comp_linebuf_runl tables linebuf
                                       bdstab
                                using  comp_linebytes_in
                                       lastline
                                       comp_linebytes_out.
      add comp_linebytes_out to comp_totalbytes_out.
    enddo.
*   write new length of (compressed) bitmap data
    perform bdstab_flush tables bdstab.
    perform bdstab_set_4byte_int tables bdstab
                                 using bdstab_totalbytesofs
                                       comp_totalbytes_out.
  else.
    do otf_bminfo-h_pix times.
      do otf_bminfo-bytes_per_row times.
        perform bm_file_getbyte using bm_fileofs byte.
        add 1 to bm_fileofs.
        perform bdstab_putbyte tables bdstab using byte.
      enddo.
    enddo.
  endif.
else.
  do otf_bminfo-h_pix times.
    perform linebuf_init tables linebuf.
    if sy-index < otf_bminfo-h_pix.
      lastline = c_false.
    else.
      lastline = c_true.
    endif.
    perform bitbuf using c_bitbuf_clear
                         c_bitbuf_whitepix
                         bufbyte.
    src_bytes_consumed = dst_bytes_written = 0.
    pixels_read_in_row = 0.
    while pixels_read_in_row < otf_bminfo-w_pix.
***********   LOLLLLLLLLLLLLLLLL

tabixn = bm_fileofs div c_bm_file_linelen.
if tabixn <> tabixo.
  tabixo = tabixn.
  add 1 to tabixn.
  read table bm_file index tabixn.
  if sy-subrc = 0.
    l_ofs = bm_fileofs mod c_bm_file_linelen.
    byte = bm_file-l+l_ofs(1).
  else.
    byte = 0.
  endif.
else.
    l_ofs = bm_fileofs mod c_bm_file_linelen.
    byte = bm_file-l+l_ofs(1).
endif.
************
*     perform bm_file_getbyte using bm_fileofs byte.
      add 1 to bm_fileofs.
      add 1 to src_bytes_consumed.
      case otf_bminfo-bitsperpix.
        when 4.                      "one byte contains 2 pixel
          nibble1 = byte div 16.     "upper nibble
          nibble2 = byte mod 16.     "lower nibble
          coltabix = 1 + nibble1.
          read table coltab index coltabix.
          if coltab-is_white = c_true.
            perform bitbuf using c_bitbuf_push
                           c_bitbuf_whitepix
                           bufbyte.
          else.
            perform bitbuf using c_bitbuf_push
                           c_bitbuf_blackpix
                           bufbyte.
          endif.
          coltabix = 1 + nibble2.
          read table coltab index coltabix.
          if coltab-is_white = c_true.
            perform bitbuf using c_bitbuf_push
                                c_bitbuf_whitepix
                                bufbyte.
          else.
            perform bitbuf using c_bitbuf_push
                                 c_bitbuf_blackpix
                                 bufbyte.
          endif.
          add 2 to pixels_read_in_row.
        when 8.                      "one byte contains 1 pixel
          coltabix = byte + 1.
          read table coltab index coltabix.
          if coltab-is_white = c_true.
            perform bitbuf using c_bitbuf_push
                                 c_bitbuf_whitepix
                                 bufbyte.
          else.
            perform bitbuf using c_bitbuf_push
                                 c_bitbuf_blackpix
                                 bufbyte.
          endif.
          add 1 to pixels_read_in_row.
        endcase.
      if sy-subrc = 1 or pixels_read_in_row >= otf_bminfo-w_pix.
        if compress_bitmap = 'X'.
          perform linebuf_putbyte tables linebuf using bufbyte.
        else.
          perform bdstab_putbyte tables bdstab using bufbyte.
        endif.
        add 1 to dst_bytes_written.
        perform bitbuf using c_bitbuf_clear
                             c_bitbuf_whitepix
                             bufbyte.
      endif.
    endwhile.
*   consume remaining color bitmap input bytes
    while src_bytes_consumed < otf_bminfo-bytes_per_row.
      perform bm_file_getbyte using bm_fileofs byte.
      add 1 to bm_fileofs.
      add 1 to src_bytes_consumed.
    endwhile.
*   write remaining monochrome bitmap output bytes (4-byte padding)
    while dst_bytes_written < final_bytes_per_row.
      if compress_bitmap = 'X'.
        perform linebuf_putbyte tables linebuf using c_bitbuf_whitepix.
      else.
        perform bdstab_putbyte tables bdstab using c_bitbuf_whitepix.
      endif.
      add 1 to dst_bytes_written.
    endwhile.
    if compress_bitmap = 'X'.
*     run-length compress linebuf:
*     we do NOT include the 4 byte padding bytes at end of each line!
*     so we read only the actual bytes from buffer, not the filled bytes
      comp_linebytes_in = final_bytes_per_row_act.
      perform comp_linebuf_runl tables linebuf
                                       bdstab
                                using  comp_linebytes_in
                                       lastline
                                       comp_linebytes_out.
      add comp_linebytes_out to comp_totalbytes_out.
    endif.
  enddo.
* write new length of (compressed) bitmap data
  if compress_bitmap = 'X'.
    perform bdstab_flush tables bdstab.
    perform bdstab_set_4byte_int tables bdstab
                                 using bdstab_totalbytesofs
                                       comp_totalbytes_out.
  endif.
endif.
if compress_bitmap <> 'X'.
  perform bdstab_flush tables bdstab.
endif.
bds_bytecount = bdstab_bytecount.
endform.

* fill OTF table from BDS bitmap data
form fill_otf_from_bds_content tables bdstab type sbdst_content
                                      otf    structure itcoo
                               using  value(bitmaptype)
                                      value(resident)
                                      value(act_dpi)
                                      value(bds_bytecount).
field-symbols: <p>.
constants: max_rdbytes type i value 66.
data: numrdbytes(2) type n,
      byte type x,
      ofs type i,
      bds_lineofs type i,
      bds_linesize type i,
      bds_valid_bytes type i,
      bds_tabix like sy-tabix,
      expected_filesize type i,
      bytes_per_row type i,
      bytes_per_row_act type i,
      rdtype(1),
      x66(66) type x.

perform bdstab_init_readonly tables bdstab.
* check / set bitmap header
perform bdstab_get_imageheader tables bdstab
                               using ofs
                                     c_true
                                     act_dpi
                                     c_true
                                     resident
                                     expected_filesize
                                     bytes_per_row
                                     bytes_per_row_act.
if sy-subrc <> 0.
  raise err_bad_bitmap_format.
endif.
if bds_bytecount < expected_filesize.
*  raise err_premature_eof.
endif.
if otf_bminfo-is_monochrome = 'X'.
  rdtype = 'J'.
else.
  rdtype = 'I'.
endif.
* build OTF RD commands from BDS data
clear otf.
otf-tdprintcom = pc_id_raw_data.
otf-tdprintpar(1) = rdtype.
otf-tdprintpar+1(1) = space.
otf-tdprintpar+2(2) = '00'.
ofs = 0. numrdbytes = 0.
while bds_bytecount > 0.
  perform bdstab_get66bytes tables bdstab
                            using ofs
                                  x66
                                  bds_valid_bytes.
  if bds_valid_bytes > bds_bytecount.
    bds_valid_bytes = bds_bytecount.
  elseif bds_valid_bytes <= 0.
    exit.
  endif.
  assign otf-tdprintpar+4(66) to <p> type 'X'.
  <p> = x66.
  numrdbytes = bds_valid_bytes.
  otf-tdprintpar+2(2) = numrdbytes.
  append otf.
  bds_bytecount = bds_bytecount - bds_valid_bytes.
endwhile.
endform.

* fill BMINFO from BDS bitmap header
* OFS will point to the start of bitmap/colormap data when finished
form bdstab_get_imageheader tables bdstab type sbdst_content
                            using  ofs type i
                                   set_dpi_value type ty_boolean
                                   act_dpi
                                   set_res_value type ty_boolean
                                   resident
                                   expected_filesize type i
                                   bytes_per_row type i
                                   bytes_per_row_act type i.
statics: byte type x,
         magic like c_otf_rd_otfbitma,
         ofs_tmp type i,
         byte_lo type x,
         byte_hi type x,
         mod type i.

magic = c_otf_rd_otfbitma.
ofs = 0.
do 8 times.                               "OTFbitma
  perform bdstab_getbyte tables bdstab
                                using ofs byte.
  if byte <> magic(2).
    sy-subrc = 1. exit.
  else.
    shift magic by 2 places.
    sy-subrc = 0.
  endif.
enddo.
ofs_tmp = ofs.
otf_bminfo-new_rd_format = c_true.
do 4 times.                               "new format, 4*FF
  perform bdstab_getbyte tables bdstab
                                using ofs byte.
  if byte <> c_otf_rd_ff.
    sy-subrc = 1. exit.
  else.
    sy-subrc = 0.
  endif.
enddo.
check sy-subrc = 0.
perform bdstab_getbyte tables bdstab         "formatid
                              using ofs byte.
check sy-subrc = 0.
case byte.
  when c_otf_rd_formatid_bmon.
    otf_bminfo-bmtype = c_itf_hex_bmon.
    otf_bminfo-is_monochrome = c_true.
  when c_otf_rd_formatid_bcol.
    otf_bminfo-bmtype = c_itf_hex_bcol.
    otf_bminfo-is_monochrome = c_false.
  when others.
    sy-subrc = 1. exit.
endcase.
perform bdstab_getbyte tables bdstab          "subformatid
                              using ofs byte.
check sy-subrc = 0.
case byte.
  when c_otf_rd_subformatid_bds.
  when others.
    sy-subrc = 1. exit.
endcase.
ofs_tmp = ofs.
perform bdstab_getbyte tables bdstab          "formatpar1: resi/nonresi
                              using ofs byte.
check sy-subrc = 0.
byte_lo = byte mod 16.
byte_hi = ( byte div 16 ) * 16.
case byte_lo.
  when c_otf_rd_formatpar1_resi.
    otf_bminfo-is_resident = c_true.
  when c_otf_rd_formatpar1_nonresi.
    otf_bminfo-is_resident = c_false.
  when others.
    sy-subrc = 1. exit.
endcase.
case byte_hi.
  when c_otf_rd_formatpar1_hi_nocomp.
    otf_bminfo-is_compressed = c_false.
  when c_otf_rd_formatpar1_hi_runl.
    otf_bminfo-is_compressed = c_true.
  when others.
    sy-subrc = 1. exit.
endcase.
if otf_bminfo-is_resident <> resident and set_res_value = c_true.
  ofs = ofs_tmp.
  if resident = c_true.
    byte = c_otf_rd_formatpar1_resi.
    otf_bminfo-is_resident = c_true.
  else.
    byte = c_otf_rd_formatpar1_nonresi.
    otf_bminfo-is_resident = c_false.
  endif.
* left half-byte is compress option and must be restore
  add byte_hi to byte.
  perform bdstab_setbyte tables bdstab
                         using  ofs byte.
endif.
perform bdstab_getbyte tables bdstab          "formatpar2
                              using ofs byte.
check sy-subrc = 0.
ofs_tmp = ofs.
perform bdstab_get4byte_int tables bdstab
                            using  ofs otf_bminfo-w_tw.
perform bdstab_get4byte_int tables bdstab
                            using  ofs otf_bminfo-h_tw.
perform bdstab_get4byte_int tables bdstab
                            using  ofs otf_bminfo-w_pix.
perform bdstab_get4byte_int tables bdstab
                            using  ofs otf_bminfo-h_pix.
perform bdstab_get2byte_int tables bdstab
                            using  ofs otf_bminfo-dpi.
if otf_bminfo-dpi <> act_dpi and set_dpi_value = c_true.
  otf_bminfo-dpi = act_dpi.
  otf_bminfo-w_tw = ( 1440 * otf_bminfo-w_pix ) / act_dpi.
  otf_bminfo-h_tw = ( 1440 * otf_bminfo-h_pix ) / act_dpi.
  ofs = ofs_tmp.
  perform bdstab_set_4byte_int tables bdstab
                              using  ofs otf_bminfo-w_tw.
  perform bdstab_set_4byte_int tables bdstab
                              using  ofs otf_bminfo-h_tw.
  perform bdstab_set_4byte_int tables bdstab
                              using  ofs otf_bminfo-w_pix.
  perform bdstab_set_4byte_int tables bdstab
                              using  ofs otf_bminfo-h_pix.
  perform bdstab_set_2byte_int tables bdstab
                              using  ofs otf_bminfo-dpi.
endif.
perform bdstab_get2byte_int tables bdstab
                            using  ofs otf_bminfo-bitsperpix.
perform bdstab_get2byte_int tables bdstab
                            using  ofs otf_bminfo-coltabsize.
perform bdstab_get4byte_int tables bdstab
                            using  ofs otf_bminfo-numdatabytes.
check sy-subrc = 0.
* calculate bytes per row actual and 4-byte padded
if otf_bminfo-is_monochrome = c_true or otf_bminfo-coltabsize = 2.
  bytes_per_row_act = otf_bminfo-w_pix div 8.
  mod = otf_bminfo-w_pix mod 8.
  if mod > 0.
    add 1 to bytes_per_row_act.
  endif.
else.
  case otf_bminfo-coltabsize.
    when 16.
      bytes_per_row_act = otf_bminfo-w_pix div 2.
      mod = otf_bminfo-w_pix mod 2.
      if mod > 0.
        add 1 to bytes_per_row_act.
      endif.
    when 256.
      bytes_per_row_act = otf_bminfo-w_pix.
  endcase.
endif.
otf_bminfo-bytes_per_row_act = bytes_per_row_act.
bytes_per_row = bytes_per_row_act.
mod = bytes_per_row mod 4.
if mod > 0.
  bytes_per_row = bytes_per_row + ( 4 - mod ).
endif.
otf_bminfo-bytes_per_row = bytes_per_row.
if otf_bminfo-is_monochrome = c_true.
  expected_filesize = ofs + 90 + otf_bminfo-numdatabytes.
else.
  expected_filesize = ofs + 90 + otf_bminfo-coltabsize * 6
                      + otf_bminfo-numdatabytes.
endif.
if otf_bminfo-new_rd_format = c_true.
  do c_otf_rd_imageid_len times.
    perform bdstab_getbyte tables bdstab
                                  using ofs byte.
  enddo.
endif.
endform.


***********************************************************************
* FORM CREATE_OTF_BITMAP_COMMAND
* creates bitmap command for OTF data stream
* -> P_WIDTH     : width in twip
* -> P_HEIGHT    : height in twip
* -> P_RESIDENT  : flag if bitmap is resident in printer memory
* -> P_FUNCTION  : 'D' (definition), 'R' (reference),
*                  'I' (information for "old" graphics)
* -> P_AUX       : reserved
* -> P_DOCID     : BDS identification
* -> P_BACK      : background key
* <- P_OTF       : otf line with bitmap (BM) identifier
***********************************************************************
form create_otf_bitmap_command using    p_width    type tdwidthtw
                                        p_height   type tdhghttw
                                        p_resident type tdresident
                                        p_function type c
                                        p_aux      type c
                                        p_docid    type bds_docid
                                        p_back     type n
                               changing p_otf      like itcoo.

  clear p_otf.
  p_otf-tdprintcom = pc_id_bitmap.
  p_otf-tdprintpar(5)     = p_width.
  p_otf-tdprintpar+5(5)   = p_height.
  if p_resident = 'X'.
    p_otf-tdprintpar+10(1)  = c_true.
  else.
    p_otf-tdprintpar+10(1)  = c_false.
  endif.
  p_otf-tdprintpar+11(1)  = p_function.
  p_otf-tdprintpar+12(4)  = p_aux.
  p_otf-tdprintpar+16(42) = p_docid.
  p_otf-tdprintpar+58(1)  = p_back.

endform.


***********************************************************************
* FORM GET_BITMAP_ATTRIBUTES_FROM_OTF
* receives OTF BM command and returns width and height
* -> P_OTF_BM : otf bitmap command
* <- P_HEIGHT : bitmap height in twips
* <- P_WIDTH  : bitmap width in twips
***********************************************************************
form get_bitmap_attributes_from_otf using    p_otf_bm like itcoo
                                    changing p_height type i
                                             p_width  type i.

  clear: p_height, p_width.
  check p_otf_bm-tdprintcom = pc_id_bitmap.

  p_width  = p_otf_bm-tdprintpar(5).
  p_height = p_otf_bm-tdprintpar+5(5).

endform.
