require 'uuid' 

class XlsConfig
  HEADER_FORMAT = {}
  def initialize xls, sheet, report_no
    @report_no = report_no
    @xls    = xls
    @sheet  = sheet
    @pos_y  = 0
  end

  def header pos, text 
    @sheet.add_cell @xls.cell pos[0], pos[1], text, {align: 'center'}
    @sheet.merge_cells pos[0], pos[1], pos[0] + 5, pos[1]

    unless @report_no.blank?
      @sheet.add_cell @xls.cell pos[0], pos[1] + 1, '[Report No]', {}
      @sheet.add_cell @xls.cell pos[0] + 1, pos[1] + 1, @report_no.to_s, {}
      @sheet.merge_cells pos[0] + 1, pos[1] + 1, pos[0] + 3, pos[1] + 1
    end

    @sheet.add_cell @xls.cell pos[0] + 4, pos[1] + 1, '[Date Time]', {}
    @sheet.add_cell @xls.cell pos[0] + 5, pos[1] + 1, DateTime.current.strftime('%d/%m/%Y %H:%M:%S'), {}   
    @sheet.merge_cells pos[0] + 5, pos[1] + 1, pos[0] + 6, pos[1] + 1
    
    @pos_y  = pos[1] + 3
  end

  def add_filter filters, configs#, &block
    ret_y = 0
    
    (filters || {}).each{|name, _value|
      config = configs[:data].select{|e| 
        e[:name].to_s == name.to_s
      }.first || {}

      caption = _value["caption"] 
      caption = _value[:caption] if caption.blank? 

      value   = _value["value"] 
      value   = _value[:value] if value.blank? 
       
      type    = config[:type] || 'text'
      
      if value.nil? or (value.to_s == '')
      else
        @sheet.add_cell @xls.cell 0, @pos_y, caption
        x_value = value
        x_value = yield name, value if block_given?

        @sheet.add_cell @xls.cell 1, @pos_y, x_value#, {type: type}

        @pos_y += 1
      end 
    }

    @pos_y
  end

  def report_no text
    @sheet.add_cell @xls.cell 0, 1, text, {}
  end
end

class XlsExporter
  def initialize
    @format = {}
  end

  def add_report_header report_no, sheet, &block
    c = XlsConfig.new self, sheet, report_no
    block.call c
  end

  def export &block
    tmp_file = Tempfile.new([UUID.new.generate.to_s, ".xls"])
    tmp_file.binmode

    workbook = Java::jxl.Workbook.createWorkbook(java.io.File.new tmp_file.path)

    block.call workbook

    workbook.write
    workbook.close 

    hash = XFileUtils.store_tmp_file tmp_file.read

    tmp_file.close
    tmp_file.unlink

    hash
  end

  def __set_border_line_style format, style_text
    return if format.blank?
    style_list = 
    pos = [:TOP, :RIGHT, :BOTTOM, :LEFT]
    style_text.to_s.split(' ').each_with_index{|ss, index|
      ss = ss.strip
      style_sym = ss.upcase.to_sym
      unless ss.blank?
        if Java::jxl.format.BorderLineStyle.constants.include? style_sym
          pos_sym = pos[index]
          unless pos_sym.blank?
            format.set_border Java::jxl.format.Border.const_get(pos_sym), Java::jxl.format.BorderLineStyle.const_get(style_sym)
          end
        end
      end
    }
  end

  def __set_back_ground_color format, color
    return if format.blank?
    return if color.blank?

    sym = color.to_s.upcase.to_sym

    if Java::jxl.format.Colour.constants.include? sym
      format.set_background Java::jxl.format.Colour.const_get sym
    end
  end

  def __total_header_row columns, total = 0
    ret = total
    columns.each{|column|
      if column[:columns].is_a? Array 
        ret += 1
        x = __total_header_row column[:columns], ret
        ret = x if x > ret
      end
    }
    ret
  end

  def add_grid_header sheet, pos, columns, a_rows
    data_index = {}
    total_bottom = {}

    ret_y = __add_grid_header sheet, pos[0], pos[1], columns, data_index
    
    rows = JSON.parse a_rows.to_json
    row_count = 0
    total_row = rows.size
    rows.each_with_index{|row, row_index|
      row_count += 1
      row.each{|k, v|
        pos_x = (data_index[k] || {})[:pos_x]
        conf  = ((data_index[k] || {})[:conf] || {})
        type = conf[:type] || 'text'
        total = conf[:total] || false
        if type == 'number'
          if total
            total_bottom[k] = 0 if total_bottom[k].nil?

            total_bottom[k] += v.to_s.to_d 
          end
        end

        unless pos_x.nil?
          if total_row == row_count
            conf[:border] = ['-', 'THIN', 'THIN', 'THIN'].join ' '
          else
            conf[:border] = ['-', 'THIN', '-', 'THIN'].join ' '
          end

          sheet.add_cell cell pos_x, ret_y + row_index, v, conf
        end
      }
    }
    
    total_bottom.each{|k, v|
      pos_x = (data_index[k] || {})[:pos_x]
      conf  = ((data_index[k] || {})[:conf] || {})

      unless pos_x.blank?
        conf[:border] = 'THIN THIN THIN THIN'
        conf[:background] = 'LIGHT_GREEN'
        sheet.add_cell cell pos_x, ret_y +row_count , v, (conf || {})
      end
    }
    

  end

  def add_grid_rows headers, rows

  end


  def __add_grid_header sheet, x, y, columns, data_index
    
    pos_x = x 
    pos_y = y

    ret_y = y + 1
 
    child_size = 0

    (columns || []).each_with_index{|column, index|
      #pos_x += index
      
      sheet.set_column_view pos_x + index, column[:width] unless column[:width].blank?

      cell_conf = {}
      cell_conf[:align] = column[:align] unless column[:align].blank?
      cell_conf[:border] = 'THIN THIN THIN THIN'
      cell_conf[:background] = 'LIGHT_GREEN'
      
      child_size = 0
      if !column[:columns].blank? and column[:columns].is_a? Array
        child_size = column[:columns].size
      end

      if child_size > 0
        cell_conf[:align] = 'center' 
        sheet.merge_cells pos_x + index, pos_y , (pos_x + index + (child_size - 1)), pos_y
      end

      case column[:type]
      when 'number'
        cell_conf[:align] = 'right'
      when 'date'
        cell_conf[:align] = 'center'
      end
      cell_conf[:align] = column[:align] unless column[:align].blank?
       
      sheet.add_cell cell pos_x + index, pos_y, column[:text], cell_conf
      unless column[:data_index].blank?
        data_index[column[:data_index]] = {} if data_index[column[:data_index]].nil?

        data_index[column[:data_index]][:pos_x] = pos_x + index
        data_index[column[:data_index]][:conf] = {
          align: column[:align], 
          format: column[:format], 
          type: column[:type],
          total: (column[:total] || false)
        }
      
      end
      
      if child_size > 0
        yy = __add_grid_header sheet, pos_x + index, (pos_y + 1), column[:columns], data_index
        ret_y = yy if yy > ret_y
        pos_x += (child_size - 1)
      end

      unless column[:row_span].blank?
        sheet.merge_cells pos_x + index, pos_y , (pos_x + index), pos_y + (column[:row_span] - 1)
      end
    } 
    ret_y
  end

  def add_grid sheet, x, y, rows, configs
    pos_x = x
    pos_y = y

    ret_pos_y = y

    total_bottom = {}

    (configs || {}).each_with_index{|(col_name, config), index|
      xx = pos_x + index

      unless config[:total].blank?
        total_bottom[col_name] = 0 if total_bottom[col_name].nil?
      end

      sheet.set_column_view xx, config[:width] unless config[:width].blank?
 
      conf = config.clone
      conf[:type] = 'text'
      conf[:border] = 'THIN THIN THIN THIN'
      conf[:background] = 'GRAY_25'
      conf[:background] = conf[:header_bg_color] unless conf[:header_bg_color].blank?
      case config[:type]
      when 'number'
        if config[:align].blank?
          conf[:align] = 'right' 
        end
      when 'date'
        if config[:align].blank?
          conf[:align] = 'center'
        end
      end

      sheet.add_cell cell xx, pos_y, config[:caption], conf
      
      total = (rows || []).size

      (rows || []).each_with_index{|row, row_index|
        content = row[col_name]

        unless config[:total].blank?
          total_bottom[col_name] += content.to_s.to_d
        end

        conf = config.clone
        if conf[:border].blank?
          conf[:border] = '0 THIN 0 THIN'
          if (row_index + 1) == total
            conf[:border] = '0 THIN THIN THIN'
          end
        end

        sheet.add_cell cell xx, pos_y + row_index + 1, content, conf
        ret_pos_y = (pos_y + row_index + 1)

        unless config[:total].blank?
          if (row_index + 1) == total 
            conf = config.clone
            conf[:border] = 'THIN THIN THIN THIN'
            conf[:background] = 'light_green'
            sheet.add_cell cell xx, pos_y + row_index + 2, (total_bottom[col_name] || 0), conf
            ret_pos_y = (pos_y + row_index + 2)
          end
        end
      }
    }
    ret_pos_y
  end

  def __set_align format, align
    case align
    when 'center'
      format.set_alignment Java::jxl.format.Alignment.CENTRE
    when 'right'
      format.set_alignment Java::jxl.format.Alignment.RIGHT
    else
      format.set_alignment Java::jxl.format.Alignment.LEFT
    end
  end

  def __create_text_cell x, y, text
    Java::jxl.write.Label.new x, y, text
  end

  def __create_number_cell x, y, number
    Java::jxl.write.Number.new x, y, number.to_s.to_d.to_f
  end

  def cell x, y, content, config = {}
     
    cell = nil

    case config[:type]
    when 'text'
      cell = __create_text_cell x, y, content.to_s
      

    when 'number'
      cell = __create_number_cell x, y, content.to_s

    when 'date'
      val = content.to_s
      begin
        format = '%Y-%m-%d'
        format = config[:format] unless config[:format].blank? 
        val = content.to_date.strftime format
      rescue
        val = ''#'Invalid date format!'
      end


      cell = __create_text_cell x, y, val

    else
      cell = __create_text_cell x, y, content.to_s
    end

    unless cell.nil?
      cell.set_cell_format __format config
    end 
    cell
  end

  def __format config
    format = nil
    format_key = []
    config.keys.sort.each{|e|
      format_key.push config[e]
    }
    format_key = format_key.join ''
    
    return @format[format_key] unless @format[format_key].nil?

    case config[:type]
    when 'text'
      format = Java::jxl.write.WritableCellFormat.new
      __set_align format, config[:align]
       
    when 'number'
      unless config[:format].blank?
        format = Java::jxl.write.WritableCellFormat.new Java::jxl.write.NumberFormat.new config[:format]
      else
        format = Java::jxl.write.WritableCellFormat.new Java::jxl.write.NumberFormat.new "0"
      end
      
      __set_align format, config[:align] || 'right'

    when 'date'
      format = Java::jxl.write.WritableCellFormat.new
      __set_align format, config[:align] || 'center'

    else
      format = Java::jxl.write.WritableCellFormat.new
      __set_align format, config[:align]
    end

    unless format.nil?
      __set_border_line_style format, config[:border]
      __set_back_ground_color format, config[:background]
    end

    @format[format_key] = format

    format
  end

  def self.get_tmp_xls_by_hash hash
    XFileUtils.get_tmp_file_by_hash hash
  end
end