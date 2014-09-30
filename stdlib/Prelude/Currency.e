module Currency where

import Function
import Relation
import List
import Syntax.List using map

field currencyName : String -- human readable description
field currencyCode : String -- ISO 4217 3-letter currency code
field currencySymbol : String -- "$", "¥", etc

currencies : [currencyName, currencyCode, currencySymbol]
currencies = materialize (relation currenciesList)

currenciesList : List {currencyName, currencyCode, currencySymbol}
currenciesList = map ((n, c, s) -> {currencyCode = c, currencyName = n, currencySymbol = s}) ' [
  ("Albania Lek", "ALL", "Lek"),
  ("Afghanistan Afghani", "AFN", "؋"),
  ("Argentina Peso", "ARS", "$"),
  ("Aruba Guilder", "AWG", "ƒ"),
  ("Australia Dollar", "AUD", "$"),
  ("Azerbaijan New Manat", "AZN", "ман"),
  ("Bahamas Dollar", "BSD", "$"),
  ("Barbados Dollar", "BBD", "$"),
  ("Belarus Ruble", "BYR", "p."),
  ("Belize Dollar", "BZD", "BZ$"),
  ("Bermuda Dollar", "BMD", "$"),
  ("Bolivia Boliviano", "BOB", "$b"),
  ("Bosnia and Herzegovina Convertible Marka", "BAM", "KM"),
  ("Botswana Pula", "BWP", "P"),
  ("Bulgaria Lev", "BGN", "лв"),
  ("Brazil Real", "BRL", "R$"),
  ("Brunei Darussalam Dollar", "BND", "$"),
  ("Cambodia Riel", "KHR", "៛"),
  ("Canada Dollar", "CAD", "$"),
  ("Cayman Islands Dollar", "KYD", "$"),
  ("Chile Peso", "CLP", "$"),
  ("China Yuan Renminbi", "CNY", "¥"),
  ("Colombia Peso", "COP", "$"),
  ("Costa Rica Colon", "CRC", "₡"),
  ("Croatia Kuna", "HRK", "kn"),
  ("Cuba Peso", "CUP", "₱"),
  ("Czech Republic Koruna", "CZK", "Kč"),
  ("Denmark Krone", "DKK", "kr"),
  ("Dominican Republic Peso", "DOP", "RD$"),
  ("East Caribbean Dollar", "XCD", "$"),
  ("Egypt Pound", "EGP", "£"),
  ("El Salvador Colon", "SVC", "$"),
  ("Estonia Kroon", "EEK", "kr"),
  ("Euro", "EUR", "€"),
  ("Falkland Islands (Malvinas) Pound", "FKP", "£"),
  ("Fiji Dollar", "FJD", "$"),
  ("Ghana Cedis", "GHC", "¢"),
  ("Gibraltar Pound", "GIP", "£"),
  ("Guatemala Quetzal", "GTQ", "Q"),
  ("Guernsey Pound", "GGP", "£"),
  ("Guyana Dollar", "GYD", "$"),
  ("Honduras Lempira", "HNL", "L"),
  ("Hong Kong Dollar", "HKD", "$"),
  ("Hungary Forint", "HUF", "Ft"),
  ("Iceland Krona", "ISK", "kr"),
  ("India Rupee", "INR", "₹"),
  ("Indonesia Rupiah", "IDR", "Rp"),
  ("Iran Rial", "IRR", "﷼"),
  ("Isle of Man Pound", "IMP", "£"),
  ("Israel Shekel", "ILS", "₪"),
  ("Jamaica Dollar", "JMD", "J$"),
  ("Japan Yen", "JPY", "¥"),
  ("Jersey Pound", "JEP", "£"),
  ("Kazakhstan Tenge", "KZT", "лв"),
  ("Korea (North) Won", "KPW", "₩"),
  ("Korea (South) Won", "KRW", "₩"),
  ("Kyrgyzstan Som", "KGS", "лв"),
  ("Laos Kip", "LAK", "₭"),
  ("Latvia Lat", "LVL", "Ls"),
  ("Lebanon Pound", "LBP", "£"),
  ("Liberia Dollar", "LRD", "$"),
  ("Lithuania Litas", "LTL", "Lt"),
  ("Macedonia Denar", "MKD", "ден"),
  ("Malaysia Ringgit", "MYR", "RM"),
  ("Mauritius Rupee", "MUR", "₨"),
  ("Mexico Peso", "MXN", "$"),
  ("Mongolia Tughrik", "MNT", "₮"),
  ("Mozambique Metical", "MZN", "MT"),
  ("Namibia Dollar", "NAD", "$"),
  ("Nepal Rupee", "NPR", "₨"),
  ("Netherlands Antilles Guilder", "ANG", "ƒ"),
  ("New Zealand Dollar", "NZD", "$"),
  ("Nicaragua Cordoba", "NIO", "C$"),
  ("Nigeria Naira", "NGN", "₦"),
  ("Korea (North) Won", "KPW", "₩"),
  ("Korea (South) Won", "KRW", "₩"),
  ("Norway Krone", "NOK", "kr"),
  ("Oman Rial", "OMR", "﷼"),
  ("Pakistan Rupee", "PKR", "₨"),
  ("Panama Balboa", "PAB", "B/."),
  ("Paraguay Guarani", "PYG", "Gs"),
  ("Peru Nuevo Sol", "PEN", "S/."),
  ("Philippines Peso", "PHP", "₱"),
  ("Poland Zloty", "PLN", "zł"),
  ("Qatar Riyal", "QAR", "﷼"),
  ("Romania New Leu", "RON", "lei"),
  ("Russia Ruble", "RUB", "руб"),
  ("Saint Helena Pound", "SHP", "£"),
  ("Saudi Arabia Riyal", "SAR", "﷼"),
  ("Serbia Dinar", "RSD", "Дин."),
  ("Seychelles Rupee", "SCR", "₨"),
  ("Singapore Dollar", "SGD", "$"),
  ("Solomon Islands Dollar", "SBD", "$"),
  ("Somalia Shilling", "SOS", "S"),
  ("South Africa Rand", "ZAR", "R"),
  ("Korea (South) Won", "KRW", "₩"),
  ("Sri Lanka Rupee", "LKR", "₨"),
  ("Sweden Krona", "SEK", "kr"),
  ("Switzerland Franc", "CHF", "CHF"),
  ("Suriname Dollar", "SRD", "$"),
  ("Syria Pound", "SYP", "£"),
  ("Taiwan New Dollar", "TWD", "NT$"),
  ("Thailand Baht", "THB", "฿"),
  ("Trinidad and Tobago Dollar", "TTD", "TT$"),
  ("Turkey Lira", "TRY", "₺"),
  ("Tuvalu Dollar", "TVD", "$"),
  ("Ukraine Hryvna", "UAH", "₴"),
  ("United Kingdom Pound", "GBP", "£"),
  ("United States Dollar", "USD", "$"),
  ("Uruguay Peso", "UYU", "$U"),
  ("Uzbekistan Som", "UZS", "лв"),
  ("Venezuela Bolivar", "VEF", "Bs"),
  ("Viet Nam Dong", "VND", "₫"),
  ("Yemen Rial", "YER", "﷼"),
  ("Zimbabwe Dollar", "ZWD", "Z$")]

