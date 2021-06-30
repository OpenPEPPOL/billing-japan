<!--

            Copyright (C) 2020-2023 OpenPEPPOL AISBL

            Licensed under the Apache License, Version 2.0 (the "License");
            you may not use this file except in compliance with the License.
            You may obtain a copy of the License at

                    http://www.apache.org/licenses/LICENSE-2.0

            Unless required by applicable law or agreed to in writing, software
            distributed under the License is distributed on an "AS IS" BASIS,
            WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
            See the License for the specific language governing permissions and
            limitations under the License.

-->
<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
  <ns prefix="ext" uri="urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2" />
  <ns prefix="cbc" uri="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2" />
  <ns prefix="cac" uri="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2" />
  <ns prefix="qdt" uri="urn:oasis:names:specification:ubl:schema:xsd:QualifiedDataTypes-2" />
  <ns prefix="udt" uri="urn:oasis:names:specification:ubl:schema:xsd:UnqualifiedDataTypes-2" />
  <ns prefix="cn" uri="urn:oasis:names:specification:ubl:schema:xsd:CreditNote-2" />
  <ns prefix="ubl" uri="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2" />
  <ns prefix="xs" uri="http://www.w3.org/2001/XMLSchema" />
  <phase id="Japanmodel_phase">
    <active pattern="UBL-model" />
  </phase>
  <phase id="codelist_phase">
    <active pattern="Codesmodel" />
  </phase>
  <pattern id="UBL-model">
    <rule context="/ubl:Invoice[cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode = 'JP' ]/cac:AccountingSupplierParty/cac:Party/cac:PartyTaxScheme[cac:TaxScheme/normalize-space(upper-case(cbc:ID))='CT']">
      <assert id="jp-br-01" flag="fatal" test="matches(normalize-space(cbc:CompanyID),'^T[0-9]{13}$')">[jp-br-01]- For the Japanese Suppliers, the Tax identifier must start with 'T' and must be 13 digits.</assert>
    </rule>
    <rule context="/ubl:Invoice[cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode = 'JP' ]">
      <assert id="jp-br-co-01" flag="fatal" test="(     round(cac:TaxTotal/cac:TaxSubtotal/cac:TaxCategory/xs:decimal(cbc:Percent)) != 0      and (     xs:decimal(cac:TaxTotal/cac:TaxSubtotal/cbc:TaxAmount) >= floor(xs:decimal(cac:TaxTotal/cac:TaxSubtotal/cbc:TaxableAmount) * (cac:TaxTotal/cac:TaxSubtotal/cac:TaxCategory/xs:decimal(cbc:Percent) div 100)))     and (     xs:decimal(cac:TaxTotal/cac:TaxSubtotal/cbc:TaxAmount) &lt;= ceiling(xs:decimal(cac:TaxTotal/cac:TaxSubtotal/cbc:TaxableAmount) * (cac:TaxTotal/cac:TaxSubtotal/cac:TaxCategory/xs:decimal(cbc:Percent) div 100)))     )">[jp-br-co-01]-VAT category tax amount (BT-117) = VAT category taxable amount (BT-116) x (VAT category rate (BT-119) / 100), rounded to integer. The rounded result amount SHALL be between the floor and the ceiling.</assert>
    </rule>
    <rule context="//*[@currencyID='JPY']">
      <assert id="jp-br-02" flag="fatal" test="matches(normalize-space(),'^-?[1-9][0-9]*$')">[jp-br-02]- Amount shall be integer.</assert>
    </rule>
    <rule context="ubl:Invoice/*[local-name()!='InvoiceLine']/*[@currencyID='JPY'] | ubl:Invoice/*[local-name()!='InvoiceLine']/*/*[@currencyID='JPY'] | //cac:InvoiceLine/cbc:LineExtensionAmount[@currencyID='JPY']">
      <assert id="jp-br-03" flag="fatal" test="matches(normalize-space(.),'^-?[1-9][0-9]*$')">[jp-br-03]- Amount shall be integer.</assert>
    </rule>
  </pattern>
  <pattern id="Codesmodel">
    <rule flag="fatal" context="cbc:InvoiceTypeCode | cbc:CreditNoteTypeCode">
      <assert id="jp-cl-01" flag="fatal" test="(self::cbc:InvoiceTypeCode and ((not(contains(normalize-space(.), ' ')) and contains(' 80 82 84 380 383 386 393 395 575 623 780 ', concat(' ', normalize-space(.), ' '))))) or (self::cbc:CreditNoteTypeCode and ((not(contains(normalize-space(.), ' ')) and contains(' 81 83 381 396 532 ', concat(' ', normalize-space(.), ' ')))))">[jp-cl-01]-The document type code MUST be coded by the Japanese invoice and Japanese credit note related code lists of UNTDID 1001.</assert>
    </rule>
    <rule flag="fatal" context="cac:PaymentMeans/cbc:PaymentMeansCode">
      <assert id="jp-cl-02" flag="fatal" test="( ( not(contains(normalize-space(.),' ')) and contains( ' 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 70 74 75 76 77 78 91 92 93 94 95 96 97 ZZZ Z01 Z02 ',concat(' ',normalize-space(.),' ') ) ) )">[jp-cl-02]-Payment means in a Japanese invoice MUST be coded using a restricted version of the UNCL4461 code list (adding Z01 and Z02)</assert>
    </rule>
    <rule flag="fatal" context="cac:TaxCategory/cbc:ID | cac:ClassifiedTaxCategory/cbc:ID">
      <assert id="jp-cl-03" flag="fatal" test="( ( not(contains(normalize-space(.),' ')) and contains( ' AA S Z G O E ',concat(' ',normalize-space(.),' ') ) ) )">[jp-cl-03]- Japanese invoice tax categories MUST be coded using UNCL5305 code list</assert>
    </rule>
    <rule flag="fatal" context="cbc:TaxExemptionReasonCode">
      <assert id="jp-cl-04" flag="fatal" test="((not(contains(normalize-space(.), ' ')) and contains(' ZZZ ', concat(' ', normalize-space(upper-case(.)), ' '))))">[jp-cl-04]-Tax exemption reason code identifier scheme identifier MUST belong to the ????</assert>
    </rule>
  </pattern>
</schema>
