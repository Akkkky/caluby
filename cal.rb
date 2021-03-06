# frozen_string_literal: true

require 'date'

class Calender
  def initialize
    @usage = "Usage: cal [general options] [[-y year] [-m month]]\n#{format('%48s', 'cal [general options] [-y] [[month] year]')}\n#{format('%46s', 'cal [general options] [-m month] [year]')}"

    if ARGV.empty?
      @year = Date.today.year
      @month = Date.today.month
    else
      validate_argv
      set_date
    end
  end

  # カレンダーを出力
  def output
    calender = if @month
                 set_monthry_calender
               else
                 # @month が nil の場合は年間カレンダーを出力する
                 set_yearly_calender
               end

    puts calender
  end

  # 正しく引数が渡されているかチェック
  private

  def validate_argv
    # 実装しているオプションは -m と -y のみ
    illegal_option_matchs = ARGV.grep(/-\S{2,}|-[^my]/)
    unless illegal_option_matchs.empty?
      puts "cal: illegal option -- #{illegal_option_matchs[0].gsub(/(^.*?)(-)/, '')}\n#{@usage}"
      exit(1)
    end

    # 同じオプションは複数指定できない
    duplicated = ARGV.select { |e| ARGV.count(e) > 1 }.select.grep(/-[my]/)
    unless duplicated.empty?
      puts "cal: Double #{duplicated[0]} specified.\n#{@usage}"
      exit(1)
    end

    # 引数は最大で4つまで
    if ARGV.length > 4
      puts "cal: Too many arguments.\n#{@usage}"
      exit(1)
    end

    # 引数が4つの場合は -y -m のオプションが必須
    if ARGV.length == 4
      unless ARGV.include?('-m') || ARGV.include?('-y')
        puts @usage
        exit(1)
      end
    end

    # ハイフンのない文字列が引き渡されている
    illegal_option_matchs = ARGV.grep(/^[^-0-9].*?/)
    unless illegal_option_matchs.empty?
      puts "cal: not a valid #{illegal_option_matchs[0]}"
      exit(1)
    end
  end

  # コマンドライン引数をもとにカレンダー対象日を決定する
  def set_date
    if ARGV.length == 1
      case ARGV[0]
      when '-y'
        # -y オプションだけ渡された場合はその年のすべての月を表示する
        @year = Date.today.year
        @month = nil
      when '-m'
        # -m オプションだけ渡された場合は処理できずエラー
        puts "cal: option requires an argument -- m\n#{@usage}"
        exit(1)
      else
        # 数字だけ渡された場合はその年のすべての月を表示する
        @year = ARGV[0].to_i
        @month = nil
      end
    end

    if ARGV.length == 2
      case ARGV[0]
      when '-y'
        @year = ARGV[1].to_i
        @month = nil
      when '-m'
        @year = Date.today.year
        @month = ARGV[1].to_i
      else
        @year = ARGV[1].to_i
        @month = ARGV[0].to_i
      end
    end

    if ARGV.length == 3
      case ARGV[0]
      when '-y'
        # -y オプションは数字を2つとれない
        puts "cal: -y together a given month is not supported.\n#{@usage}"
        exit(1)
      when '-m'
        @year = ARGV[2].to_i
        @month = ARGV[1].to_i
      else
        # 数字だけで3つの引数はエラー
        puts @usage
        exit(1)
      end
    end

    if ARGV.length == 4
      ARGV.each_with_index do |arg, i|
        case arg
        when '-y'
          @year = ARGV[i + 1].to_i
        when '-m'
          @month = ARGV[i + 1].to_i
        end
      end
    end

    # year は 1..9999
    unless (1..9999).cover?(@year.to_i)
      puts "cal: year '#{@year}' not in range 1..9999\n#{@usage}"
      exit(1)
    end

    # month は 1..12
    if @month && !(1..12).cover?(@month)
      puts "cal: #{@month} is neither a month number (1..12)\n#{@usage}"
      exit(1)
    end
  end

  def set_monthry_calender
    first_date = Date.new(@year, @month, 1)
    last_date = Date.new(@year, @month, -1)

    " #{@month}月 #{@year} " + make_calender(first_date, last_date)
  end

  def set_yearly_calender
    calender_ary = []

    (1..12).each do |n|
      fotter = if n != 12
                 "\n\n"
               else
                 "\n"
               end
      first_date = Date.new(@year, n, 1)
      last_date = Date.new(@year, n, -1)
      calender_ary.push(" #{n}月 " + make_calender(first_date, last_date) + fotter)
    end

    " #{@year} \n" + calender_ary.join('')
  end

  def make_calender(first_date, last_date)
    calender_ary = []
    d = 1

    (0..41).each do |i|
      if i < first_date.wday || i > (last_date.day + first_date.wday - 1)
        calender_ary[i] = '  '
      else
        calender_ary[i] = if Date.new(@year, first_date.month, d).saturday?
                            "#{format('%02d', d)}\n"
                          else
                            format('%02d', d)
                          end
        d += 1
      end
    end

    "\n 日 月 火 水 木 金 土\n #{calender_ary.join(' ')}"
  end
end

Calender.new.output
