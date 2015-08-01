module Rack
  module Utils
    DEFAULT_SEP = /[&;] */ # had /n option for ASCII-8BIT encoding in ruby

    # Stolen from Mongrel, with some small modifications:
    # Parses a query string by breaking it up at the '&'
    # and ';' characters.  You can also use this to parse
    # cookies by changing the characters used in the second
    # parameter (which defaults to '&;').
    def self.parse_query(query_string, separator = nil)
      if separator
        separator = /[#{separator}] */
      else
        separator = DEFAULT_SEP
      end
      puts "separator: ",separator
      params = {} of String => String | Array(String)
      puts query_string
      query_string.to_s.split(separator).each do |part|
        next if part.empty?


        # could use `k, v = part.split("=", 2).map { |string| unescape(string) }` unstead if fix: https://goo.gl/eio5RF
        split = part.split("=", 2).map { |string| unescape(string) }
        puts split
        k = split[0]?.to_s
        v = split[1]?.to_s

        if cur = params[k]?
          if cur.is_a? Array
            params[k] as Array(String) << v
          else
            params[k] = [cur as String, v]
          end
        else
          params[k] = v
        end
      end

      params
    end

    alias NestedParams = Nil | String | Array(String) | Array(NestedParams) | Hash(String, NestedParams)

    # parse_nested_query expands a query string into structural types. Supported
    # types are Arrays, Hashes and basic value types. It is possible to supply
    # query strings with parameters of conflicting types, in this case a
    # ParameterTypeError is raised. Users are encouraged to return a 400 in this
    # case.
    def self.parse_nested_query(query_string)
      params = {} of String => NestedParams

      query_string.to_s.split(DEFAULT_SEP).each do |part|
        # could use `k, v = part.split("=", 2).map { |string| unescape(string) }` unstead if fix: https://goo.gl/eio5RF
        split = part.split("=", 2).map { |string| unescape(string) }
        puts split
        k = split[0]?.to_s
        v = split[1]?.to_s

        normalize_params(params, k, v)
      end

      params
    end

    TBLDECWWWCOMP_ = {"%00"=>"\x00", "%01"=>"\x01", "%02"=>"\x02", "%03"=>"\x03", "%04"=>"\x04", "%05"=>"\x05", "%06"=>"\x06", "%07"=>"\a", "%08"=>"\b", "%09"=>"\t", "%0A"=>"\n", "%0a"=>"\n", "%0B"=>"\v", "%0b"=>"\v", "%0C"=>"\f", "%0c"=>"\f", "%0D"=>"\r", "%0d"=>"\r", "%0E"=>"\x0E", "%0e"=>"\x0E", "%0F"=>"\x0F", "%0f"=>"\x0F", "%10"=>"\x10", "%11"=>"\x11", "%12"=>"\x12", "%13"=>"\x13", "%14"=>"\x14", "%15"=>"\x15", "%16"=>"\x16", "%17"=>"\x17", "%18"=>"\x18", "%19"=>"\x19", "%1A"=>"\x1A", "%1a"=>"\x1A", "%1B"=>"\e", "%1b"=>"\e", "%1C"=>"\x1C", "%1c"=>"\x1C", "%1D"=>"\x1D", "%1d"=>"\x1D", "%1E"=>"\x1E", "%1e"=>"\x1E", "%1F"=>"\x1F", "%1f"=>"\x1F", "%20"=>" ", "%21"=>"!", "%22"=>"\"", "%23"=>"#", "%24"=>"$", "%25"=>"%", "%26"=>"&", "%27"=>"'", "%28"=>"(", "%29"=>")", "%2A"=>"*", "%2a"=>"*", "%2B"=>"+", "%2b"=>"+", "%2C"=>",", "%2c"=>",", "%2D"=>"-", "%2d"=>"-", "%2E"=>".", "%2e"=>".", "%2F"=>"/", "%2f"=>"/", "%30"=>"0", "%31"=>"1", "%32"=>"2", "%33"=>"3", "%34"=>"4", "%35"=>"5", "%36"=>"6", "%37"=>"7", "%38"=>"8", "%39"=>"9", "%3A"=>":", "%3a"=>":", "%3B"=>";", "%3b"=>";", "%3C"=>"<", "%3c"=>"<", "%3D"=>"=", "%3d"=>"=", "%3E"=>">", "%3e"=>">", "%3F"=>"?", "%3f"=>"?", "%40"=>"@", "%41"=>"A", "%42"=>"B", "%43"=>"C", "%44"=>"D", "%45"=>"E", "%46"=>"F", "%47"=>"G", "%48"=>"H", "%49"=>"I", "%4A"=>"J", "%4a"=>"J", "%4B"=>"K", "%4b"=>"K", "%4C"=>"L", "%4c"=>"L", "%4D"=>"M", "%4d"=>"M", "%4E"=>"N", "%4e"=>"N", "%4F"=>"O", "%4f"=>"O", "%50"=>"P", "%51"=>"Q", "%52"=>"R", "%53"=>"S", "%54"=>"T", "%55"=>"U", "%56"=>"V", "%57"=>"W", "%58"=>"X", "%59"=>"Y", "%5A"=>"Z", "%5a"=>"Z", "%5B"=>"[", "%5b"=>"[", "%5C"=>"\\", "%5c"=>"\\", "%5D"=>"]", "%5d"=>"]", "%5E"=>"^", "%5e"=>"^", "%5F"=>"_", "%5f"=>"_", "%60"=>"`", "%61"=>"a", "%62"=>"b", "%63"=>"c", "%64"=>"d", "%65"=>"e", "%66"=>"f", "%67"=>"g", "%68"=>"h", "%69"=>"i", "%6A"=>"j", "%6a"=>"j", "%6B"=>"k", "%6b"=>"k", "%6C"=>"l", "%6c"=>"l", "%6D"=>"m", "%6d"=>"m", "%6E"=>"n", "%6e"=>"n", "%6F"=>"o", "%6f"=>"o", "%70"=>"p", "%71"=>"q", "%72"=>"r", "%73"=>"s", "%74"=>"t", "%75"=>"u", "%76"=>"v", "%77"=>"w", "%78"=>"x", "%79"=>"y", "%7A"=>"z", "%7a"=>"z", "%7B"=>"{", "%7b"=>"{", "%7C"=>"|", "%7c"=>"|", "%7D"=>"}", "%7d"=>"}", "%7E"=>"~", "%7e"=>"~", "%7F"=>"\x7F", "%7f"=>"\x7F", "%80"=>"\x80", "%81"=>"\x81", "%82"=>"\x82", "%83"=>"\x83", "%84"=>"\x84", "%85"=>"\x85", "%86"=>"\x86", "%87"=>"\x87", "%88"=>"\x88", "%89"=>"\x89", "%8A"=>"\x8A", "%8a"=>"\x8A", "%8B"=>"\x8B", "%8b"=>"\x8B", "%8C"=>"\x8C", "%8c"=>"\x8C", "%8D"=>"\x8D", "%8d"=>"\x8D", "%8E"=>"\x8E", "%8e"=>"\x8E", "%8F"=>"\x8F", "%8f"=>"\x8F", "%90"=>"\x90", "%91"=>"\x91", "%92"=>"\x92", "%93"=>"\x93", "%94"=>"\x94", "%95"=>"\x95", "%96"=>"\x96", "%97"=>"\x97", "%98"=>"\x98", "%99"=>"\x99", "%9A"=>"\x9A", "%9a"=>"\x9A", "%9B"=>"\x9B", "%9b"=>"\x9B", "%9C"=>"\x9C", "%9c"=>"\x9C", "%9D"=>"\x9D", "%9d"=>"\x9D", "%9E"=>"\x9E", "%9e"=>"\x9E", "%9F"=>"\x9F", "%9f"=>"\x9F", "%A0"=>"\xA0", "%a0"=>"\xA0", "%A1"=>"\xA1", "%a1"=>"\xA1", "%A2"=>"\xA2", "%a2"=>"\xA2", "%A3"=>"\xA3", "%a3"=>"\xA3", "%A4"=>"\xA4", "%a4"=>"\xA4", "%A5"=>"\xA5", "%a5"=>"\xA5", "%A6"=>"\xA6", "%a6"=>"\xA6", "%A7"=>"\xA7", "%a7"=>"\xA7", "%A8"=>"\xA8", "%a8"=>"\xA8", "%A9"=>"\xA9", "%a9"=>"\xA9", "%AA"=>"\xAA", "%aA"=>"\xAA", "%Aa"=>"\xAA", "%aa"=>"\xAA", "%AB"=>"\xAB", "%aB"=>"\xAB", "%Ab"=>"\xAB", "%ab"=>"\xAB", "%AC"=>"\xAC", "%aC"=>"\xAC", "%Ac"=>"\xAC", "%ac"=>"\xAC", "%AD"=>"\xAD", "%aD"=>"\xAD", "%Ad"=>"\xAD", "%ad"=>"\xAD", "%AE"=>"\xAE", "%aE"=>"\xAE", "%Ae"=>"\xAE", "%ae"=>"\xAE", "%AF"=>"\xAF", "%aF"=>"\xAF", "%Af"=>"\xAF", "%af"=>"\xAF", "%B0"=>"\xB0", "%b0"=>"\xB0", "%B1"=>"\xB1", "%b1"=>"\xB1", "%B2"=>"\xB2", "%b2"=>"\xB2", "%B3"=>"\xB3", "%b3"=>"\xB3", "%B4"=>"\xB4", "%b4"=>"\xB4", "%B5"=>"\xB5", "%b5"=>"\xB5", "%B6"=>"\xB6", "%b6"=>"\xB6", "%B7"=>"\xB7", "%b7"=>"\xB7", "%B8"=>"\xB8", "%b8"=>"\xB8", "%B9"=>"\xB9", "%b9"=>"\xB9", "%BA"=>"\xBA", "%bA"=>"\xBA", "%Ba"=>"\xBA", "%ba"=>"\xBA", "%BB"=>"\xBB", "%bB"=>"\xBB", "%Bb"=>"\xBB", "%bb"=>"\xBB", "%BC"=>"\xBC", "%bC"=>"\xBC", "%Bc"=>"\xBC", "%bc"=>"\xBC", "%BD"=>"\xBD", "%bD"=>"\xBD", "%Bd"=>"\xBD", "%bd"=>"\xBD", "%BE"=>"\xBE", "%bE"=>"\xBE", "%Be"=>"\xBE", "%be"=>"\xBE", "%BF"=>"\xBF", "%bF"=>"\xBF", "%Bf"=>"\xBF", "%bf"=>"\xBF", "%C0"=>"\xC0", "%c0"=>"\xC0", "%C1"=>"\xC1", "%c1"=>"\xC1", "%C2"=>"\xC2", "%c2"=>"\xC2", "%C3"=>"\xC3", "%c3"=>"\xC3", "%C4"=>"\xC4", "%c4"=>"\xC4", "%C5"=>"\xC5", "%c5"=>"\xC5", "%C6"=>"\xC6", "%c6"=>"\xC6", "%C7"=>"\xC7", "%c7"=>"\xC7", "%C8"=>"\xC8", "%c8"=>"\xC8", "%C9"=>"\xC9", "%c9"=>"\xC9", "%CA"=>"\xCA", "%cA"=>"\xCA", "%Ca"=>"\xCA", "%ca"=>"\xCA", "%CB"=>"\xCB", "%cB"=>"\xCB", "%Cb"=>"\xCB", "%cb"=>"\xCB", "%CC"=>"\xCC", "%cC"=>"\xCC", "%Cc"=>"\xCC", "%cc"=>"\xCC", "%CD"=>"\xCD", "%cD"=>"\xCD", "%Cd"=>"\xCD", "%cd"=>"\xCD", "%CE"=>"\xCE", "%cE"=>"\xCE", "%Ce"=>"\xCE", "%ce"=>"\xCE", "%CF"=>"\xCF", "%cF"=>"\xCF", "%Cf"=>"\xCF", "%cf"=>"\xCF", "%D0"=>"\xD0", "%d0"=>"\xD0", "%D1"=>"\xD1", "%d1"=>"\xD1", "%D2"=>"\xD2", "%d2"=>"\xD2", "%D3"=>"\xD3", "%d3"=>"\xD3", "%D4"=>"\xD4", "%d4"=>"\xD4", "%D5"=>"\xD5", "%d5"=>"\xD5", "%D6"=>"\xD6", "%d6"=>"\xD6", "%D7"=>"\xD7", "%d7"=>"\xD7", "%D8"=>"\xD8", "%d8"=>"\xD8", "%D9"=>"\xD9", "%d9"=>"\xD9", "%DA"=>"\xDA", "%dA"=>"\xDA", "%Da"=>"\xDA", "%da"=>"\xDA", "%DB"=>"\xDB", "%dB"=>"\xDB", "%Db"=>"\xDB", "%db"=>"\xDB", "%DC"=>"\xDC", "%dC"=>"\xDC", "%Dc"=>"\xDC", "%dc"=>"\xDC", "%DD"=>"\xDD", "%dD"=>"\xDD", "%Dd"=>"\xDD", "%dd"=>"\xDD", "%DE"=>"\xDE", "%dE"=>"\xDE", "%De"=>"\xDE", "%de"=>"\xDE", "%DF"=>"\xDF", "%dF"=>"\xDF", "%Df"=>"\xDF", "%df"=>"\xDF", "%E0"=>"\xE0", "%e0"=>"\xE0", "%E1"=>"\xE1", "%e1"=>"\xE1", "%E2"=>"\xE2", "%e2"=>"\xE2", "%E3"=>"\xE3", "%e3"=>"\xE3", "%E4"=>"\xE4", "%e4"=>"\xE4", "%E5"=>"\xE5", "%e5"=>"\xE5", "%E6"=>"\xE6", "%e6"=>"\xE6", "%E7"=>"\xE7", "%e7"=>"\xE7", "%E8"=>"\xE8", "%e8"=>"\xE8", "%E9"=>"\xE9", "%e9"=>"\xE9", "%EA"=>"\xEA", "%eA"=>"\xEA", "%Ea"=>"\xEA", "%ea"=>"\xEA", "%EB"=>"\xEB", "%eB"=>"\xEB", "%Eb"=>"\xEB", "%eb"=>"\xEB", "%EC"=>"\xEC", "%eC"=>"\xEC", "%Ec"=>"\xEC", "%ec"=>"\xEC", "%ED"=>"\xED", "%eD"=>"\xED", "%Ed"=>"\xED", "%ed"=>"\xED", "%EE"=>"\xEE", "%eE"=>"\xEE", "%Ee"=>"\xEE", "%ee"=>"\xEE", "%EF"=>"\xEF", "%eF"=>"\xEF", "%Ef"=>"\xEF", "%ef"=>"\xEF", "%F0"=>"\xF0", "%f0"=>"\xF0", "%F1"=>"\xF1", "%f1"=>"\xF1", "%F2"=>"\xF2", "%f2"=>"\xF2", "%F3"=>"\xF3", "%f3"=>"\xF3", "%F4"=>"\xF4", "%f4"=>"\xF4", "%F5"=>"\xF5", "%f5"=>"\xF5", "%F6"=>"\xF6", "%f6"=>"\xF6", "%F7"=>"\xF7", "%f7"=>"\xF7", "%F8"=>"\xF8", "%f8"=>"\xF8", "%F9"=>"\xF9", "%f9"=>"\xF9", "%FA"=>"\xFA", "%fA"=>"\xFA", "%Fa"=>"\xFA", "%fa"=>"\xFA", "%FB"=>"\xFB", "%fB"=>"\xFB", "%Fb"=>"\xFB", "%fb"=>"\xFB", "%FC"=>"\xFC", "%fC"=>"\xFC", "%Fc"=>"\xFC", "%fc"=>"\xFC", "%FD"=>"\xFD", "%fD"=>"\xFD", "%Fd"=>"\xFD", "%fd"=>"\xFD", "%FE"=>"\xFE", "%fE"=>"\xFE", "%Fe"=>"\xFE", "%fe"=>"\xFE", "%FF"=>"\xFF", "%fF"=>"\xFF", "%Ff"=>"\xFF", "%ff"=>"\xFF", "+"=>" "}

    # Unescapes a URI escaped string with +encoding+. +encoding+ will be the
    # target encoding of the string returned, and it defaults to UTF-8
    def self.unescape(string)
      string.gsub(/\+|%[0-9a-fA-F]{2}/, TBLDECWWWCOMP_) # implementation from rubys URI.decode_www_form_component
    end
  end
end
