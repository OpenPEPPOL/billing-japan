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
  <xsl:function xmlns:xsl="http://www.w3.org/1999/XSL/Transform" name="u:gln" as="xs:boolean">
    <xsl:param name="val" />
    <xsl:variable name="length" select="string-length($val) - 1" />
    <xsl:variable name="digits" select="reverse(for $i in string-to-codepoints(substring($val, 0, $length + 1)) return $i - 48)" />
    <xsl:variable name="weightedSum" select="sum(for $i in (0 to $length - 1) return $digits[$i + 1] * (1 + ((($i + 1) mod 2) * 2)))" />
    <xsl:value-of select="(10 - ($weightedSum mod 10)) mod 10 = number(substring($val, $length + 1, 1))" />
  </xsl:function>
  <ns prefix="ext" uri="urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2" />
  <ns prefix="cbc" uri="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2" />
  <ns prefix="cac" uri="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2" />
  <ns prefix="qdt" uri="urn:oasis:names:specification:ubl:schema:xsd:QualifiedDataTypes-2" />
  <ns prefix="udt" uri="urn:oasis:names:specification:ubl:schema:xsd:UnqualifiedDataTypes-2" />
  <ns prefix="cn" uri="urn:oasis:names:specification:ubl:schema:xsd:CreditNote-2" />
  <ns prefix="ubl" uri="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2" />
  <ns prefix="u" uri="utils" />
  <ns prefix="xs" uri="http://www.w3.org/2001/XMLSchema" />
  <phase id="Japanmodel_phase">
    <active pattern="UBL-model" />
  </phase>
  <phase id="codelist_phase">
    <active pattern="Codesmodel" />
  </phase>
  <phase id="peppol_phase">
    <active pattern="PeppolReused" />
  </phase>
  <pattern id="UBL-model">
    <rule context="/ubl:Invoice[cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode = 'JP' ]/cac:AccountingSupplierParty/cac:Party/cac:PartyTaxScheme[cac:TaxScheme/normalize-space(upper-case(cbc:ID))='VAT']">
      <assert id="jp-br-01" flag="fatal" test="matches(normalize-space(cbc:CompanyID),'^T[0-9]{13}$')">[jp-br-01]-From October 1st2023, “Seller Tax identifier” (ibt-031) shall be coded by using a Registration number for Qualified Invoice in Japan, which consists of 14 digits that starts with “t”.</assert>
    </rule>
    <rule context="cac:TaxCategory/cac:TaxScheme/cbc:ID | cac:ClassifiedTaxCategory/cac:TaxScheme/cbc:ID">
      <assert id="jp-br-03" flag="fatal" test="matches(normalize-space(.),'VAT')">[jp-br-03]-Tax scheme (ibt-118-1) shall use VAT from UNECE 5153 code list. VAT means Consumption Tax in Japan.</assert>
    </rule>
    <rule context="ubl:Invoice/cac:InvoicePeriod">
      <assert id="jp-br-06" flag="fatal" test="exists(cbc:StartDate) and exists(cbc:EndDate)">[jp-br-06]-Invoice period (ibg-14) shall have both invoice period start date (ibt-073) and invoice period end date (ibt-074).</assert>
    </rule>
    <rule context="cac:InvoiceLine/cac:InvoicePeriod">
      <assert id="jp-br-07" flag="fatal" test="exists(cbc:StartDate) and exists(cbc:EndDate)">[jp-br-07]-Invoice line period (ibg-26) shall have both invoice line period start date (ibt-134) and invoice line period end date (ibt-135).</assert>
      <assert id="jp-br-08" flag="fatal" test="xs:date(cbc:StartDate) >= xs:date(../../cac:InvoicePeriod/cbc:StartDate) and xs:date(cbc:EndDate) &lt;= xs:date(../../cac:InvoicePeriod/cbc:EndDate)">[jp-br-08]-Both start date and end date of line period must be within invoice period.</assert>
    </rule>
    <rule context="/ubl:Invoice[cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode = 'JP' ]/cac:InvoiceLine">
      <assert id="jp-br-09" flag="fatal" test="(exists(cac:Price/cbc:BaseQuantity) and        ((exists(cac:AllowanceCharge[cbc:ChargeIndicator=false()]) and exists(cac:AllowanceCharge[cbc:ChargeIndicator=true()]) and (cbc:LineExtensionAmount = cbc:InvoicedQuantity * (cac:Price/cbc:PriceAmount div cac:Price/cbc:BaseQuantity) + cac:AllowanceCharge[cbc:ChargeIndicator=true()]/cbc:Amount - cac:AllowanceCharge[cbc:ChargeIndicator=false()]/cbc:Amount ))       or       (not(exists(cac:AllowanceCharge[cbc:ChargeIndicator=false()])) and exists(cac:AllowanceCharge[cbc:ChargeIndicator=true()]) and (cbc:LineExtensionAmount = cbc:InvoicedQuantity * (cac:Price/cbc:PriceAmount div cac:Price/cbc:BaseQuantity) + cac:AllowanceCharge[cbc:ChargeIndicator=true()]/cbc:Amount))       or       (exists(cac:AllowanceCharge[cbc:ChargeIndicator=false()]) and not(exists(cac:AllowanceCharge[cbc:ChargeIndicator=true()])) and (cbc:LineExtensionAmount = cbc:InvoicedQuantity * (cac:Price/cbc:PriceAmount div cac:Price/cbc:BaseQuantity) - cac:AllowanceCharge[cbc:ChargeIndicator=false()]/cbc:Amount))       or       (not(exists(cac:AllowanceCharge[cbc:ChargeIndicator=false()])) and not(exists(cac:AllowanceCharge[cbc:ChargeIndicator=true()])) and (cbc:LineExtensionAmount = cbc:InvoicedQuantity * (cac:Price/cbc:PriceAmount div cac:Price/cbc:BaseQuantity)))))     or     (not(exists(cac:Price/cbc:BaseQuantity)) and        ((exists(cac:AllowanceCharge[cbc:ChargeIndicator=false()]) and exists(cac:AllowanceCharge[cbc:ChargeIndicator=true()]) and (cbc:LineExtensionAmount = cbc:InvoicedQuantity * cac:Price/cbc:PriceAmount + cac:AllowanceCharge[cbc:ChargeIndicator=true()]/cbc:Amount - cac:AllowanceCharge[cbc:ChargeIndicator=false()]/cbc:Amount ))       or       (not(exists(cac:AllowanceCharge[cbc:ChargeIndicator=false()])) and exists(cac:AllowanceCharge[cbc:ChargeIndicator=true()]) and (cbc:LineExtensionAmount = cbc:InvoicedQuantity * (cac:Price/cbc:PriceAmount  + cac:AllowanceCharge[cbc:ChargeIndicator=true()]/cbc:Amount)))       or       (exists(cac:AllowanceCharge[cbc:ChargeIndicator=false()]) and not(exists(cac:AllowanceCharge[cbc:ChargeIndicator=true()])) and (cbc:LineExtensionAmount = cbc:InvoicedQuantity * (cac:Price/cbc:PriceAmount  - cac:AllowanceCharge[cbc:ChargeIndicator=false()]/cbc:Amount)))       or       (not(exists(cac:AllowanceCharge[cbc:ChargeIndicator=false()])) and not(exists(cac:AllowanceCharge[cbc:ChargeIndicator=true()])) and (cbc:LineExtensionAmount = cbc:InvoicedQuantity * (cac:Price/cbc:PriceAmount)))))">[jp-br-09]-Invoice line net amount (ibt-131) = Item net price (ibt-146) X Invoiced quantity (ibt-129) ÷ Item price base quantity (ibt-149) + Invoice line charge amount (ibt-141) – Invoice line allowance amount (ibt-136).</assert>
      <assert id="jp-br-co-04" flag="fatal" test="(//cac:ClassifiedTaxCategory[cac:TaxScheme/(normalize-space(upper-case(cbc:ID))='VAT')]/cbc:ID) and (//cac:ClassifiedTaxCategory[cac:TaxScheme/(normalize-space(upper-case(cbc:ID))='VAT')]/cbc:Percent)">[jp-br-co-04]-Invoice line (ibg-25), invoice line charge (ibg-28) and invoice line allowance (ibg-27) shall be categorized by both invoiced item tax category code (ibt-151) and invoiced item tax rate (ibt152).</assert>
    </rule>
    <rule context="/ubl:Invoice[cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode = 'JP' ]">
      <assert id="jp-br-04" flag="fatal" test="exists(cac:AccountingSupplierParty/cac:Party/cac:PartyTaxScheme/cbc:CompanyID)">[jp-br-04]-An Invoice shall have the Seller tax identifier (ibt-031).</assert>
      <assert id="jp-br-05" flag="fatal" test="exists(cac:InvoicePeriod) or exists(cac:InvoiceLine/cac:InvoicePeriod)">[jp-br-05]-An Invoice shall have an invoice period (ibg-14) or an Invoice line period (ibg-26).</assert>
      <assert id="jp-br-10" flag="fatal" test="starts-with(normalize-space(cbc:CustomizationID/text()), 'urn:cen.eu:en16931:2017#compliant#urn:fdc:peppol.eu:2017:poacc:billing:3.0')">[jp-br-10]-Specification identifier MUST start with the value 'urn:cen.eu:en16931:2017#compliant#urn:fdc:peppol.eu:2017:poacc:billing:3.0'.</assert>
      <assert id="jp-br-11" flag="fatal" test="/*/cbc:ProfileID and matches(normalize-space(/*/cbc:ProfileID), 'urn:fdc:peppol.eu:2017:poacc:billing:([0-9]{2}):1.0')">[jp-br-11]-Business process MUST be in the format 'urn:fdc:peppol.eu:2017:poacc:billing:NN:1.0' where NN indicates the process number.</assert>
      <assert id="jp-br-co-01" flag="fatal" test="(     round(cac:TaxTotal/cac:TaxSubtotal/cac:TaxCategory/xs:decimal(cbc:Percent)) != 0      and (     xs:decimal(cac:TaxTotal/cac:TaxSubtotal/cbc:TaxAmount) >= floor(xs:decimal(cac:TaxTotal/cac:TaxSubtotal/cbc:TaxableAmount) * (cac:TaxTotal/cac:TaxSubtotal/cac:TaxCategory/xs:decimal(cbc:Percent) div 100)))     and (     xs:decimal(cac:TaxTotal/cac:TaxSubtotal/cbc:TaxAmount) &lt;= ceiling(xs:decimal(cac:TaxTotal/cac:TaxSubtotal/cbc:TaxableAmount) * (cac:TaxTotal/cac:TaxSubtotal/cac:TaxCategory/xs:decimal(cbc:Percent) div 100)))     )">[jp-br-co-01]-Tax category tax amount (ibt-117) = Tax category taxable amount (ibt-116) X Tax category rate (ibt-119) ÷ 100, rounded to integer. The rounded result amount shall be between the floor and the ceiling.</assert>
      <assert id="jp-br-co-03" flag="fatal" test="not(exists(cbc:TaxCurrencyCode)) or cbc:TaxCurrencyCode/@schemeID = 'JPY'">[jp-br-co-03]-If tax accounting currency (ibt-006) is present, it shall be coded using JPY in ISO code list of 4217 a-3.</assert>
    </rule>
    <rule context="/cac:AllowanceCharge[cbc:ChargeIndicator=true()]">
      <assert id="jp-br-32" flag="fatal" test="exists(cac:TaxCategory[cac:TaxScheme/normalize-space(upper-case(cbc:ID))='VAT']/cbc:ID) and exists(cac:TaxCategory[cac:TaxScheme/normalize-space(upper-case(cbc:ID))='VAT']/cbc:Percent)">[jp-br-32]-Each Document level allowance (ibg-20) shall be categorized by document level allowance tax category code（ibt-095）and document level allowance tax rate（ibt-096).</assert>
    </rule>
    <rule context="/cac:AllowanceCharge[cbc:ChargeIndicator=false()]">
      <assert id="jp-br-37" flag="fatal" test="exists(cac:TaxCategory[cac:TaxScheme/normalize-space(upper-case(cbc:ID))='VAT']/cbc:ID) and exists(cac:TaxCategory[cac:TaxScheme/normalize-space(upper-case(cbc:ID))='VAT']/cbc:Percent)">[jp-br-37]-Each Document level charge (ibg-21) shall be categorized by document level charge tax category code（ibt-102）and document level charge tax rate (ibt-103).</assert>
    </rule>
    <rule context="cac:TaxTotal[cbc:TaxAmount/@currencyID=../cbc:DocumentCurrencyCode]/cac:TaxSubtotal">
      <assert id="jp-br-45" flag="fatal" test="exists(cbc:TaxableAmount)">[jp-br-45]-Each tax breakdown (ibg-23) shall have a tax category taxable amount (ibt-116).</assert>
      <assert id="jp-br-46" flag="fatal" test="exists(cbc:TaxAmount)">[jp-br-46]-Each tax breakdown (ibg-23) shall have a tax category tax amount (ibt-117).</assert>
      <assert id="jp-br-47" flag="fatal" test="exists(cac:TaxCategory[cac:TaxScheme/normalize-space(upper-case(cbc:ID))='VAT']/cbc:ID) and exists(cac:TaxCategory[cac:TaxScheme/normalize-space(upper-case(cbc:ID))='VAT']/cbc:Percent)">[jp-br-47]-Tax breakdown (ibg-23) shall be categorized by tax category code (BT-118).</assert>
      <assert id="jp-br-48" flag="fatal" test="(exists(cac:TaxCategory[cac:TaxScheme/normalize-space(upper-case(cbc:ID))='VAT']/cbc:ID) and exists(cac:TaxCategory[cac:TaxScheme/normalize-space(upper-case(cbc:ID))='VAT']/cbc:Percent)) or (cac:TaxCategory[cac:TaxScheme/normalize-space(upper-case(cbc:ID))='VAT']/normalize-space(cbc:ID)='O')">[jp-br-48]-Tax breakdown (ibg-23) shall be categorized by tax category rate (BT-119), except if the Invoice is not subject to tax.</assert>
      <assert id="jp-br-co-05" flag="fatal" test="every $category in cac:TaxCategory/cbc:ID satisfies     ((count(../../cac:AllowanceCharge[cbc:ChargeIndicator=true()][cac:TaxCategory/cbc:ID = $category]) > 0 and      count(../../cac:AllowanceCharge[cbc:ChargeIndicator=false()][cac:TaxCategory/cbc:ID = $category]) > 0 and      (cbc:TaxableAmount =      sum(//cbc:LineExtensionAmount[../cac:Item/cac:ClassifiedTaxCategory/cbc:ID = $category]) +      sum(../../cac:AllowanceCharge[cbc:ChargeIndicator=true()][cac:TaxCategory/cbc:ID = $category]/cbc:Amount) -     sum(../../cac:AllowanceCharge[cbc:ChargeIndicator=false()][cac:TaxCategory/cbc:ID = $category]/cbc:Amount)))     or     (count(../../cac:AllowanceCharge[cbc:ChargeIndicator=true()][cac:TaxCategory/cbc:ID = $category]) > 0 and      count(../../cac:AllowanceCharge[cbc:ChargeIndicator=false()][cac:TaxCategory/cbc:ID = $category]) = 0 and      (cbc:TaxableAmount =      sum(//cbc:LineExtensionAmount[../cac:Item/cac:ClassifiedTaxCategory/cbc:ID = $category]) +      sum(//cac:AllowanceCharge[cbc:ChargeIndicator=true()][cac:TaxCategory/cbc:ID = $category]/cbc:Amount)))     or     (count(../../cac:AllowanceCharge[cbc:ChargeIndicator=true()][cac:TaxCategory/cbc:ID = $category]) = 0 and      count(../../cac:AllowanceCharge[cbc:ChargeIndicator=false()][cac:TaxCategory/cbc:ID = $category]) > 0 and      (cbc:TaxableAmount =      sum(//cbc:LineExtensionAmount[../cac:Item/cac:ClassifiedTaxCategory/cbc:ID = $category]) -     sum(//cac:AllowanceCharge[cbc:ChargeIndicator=false()][cac:TaxCategory/cbc:ID = $category]/cbc:Amount)))     or     (count(../../cac:AllowanceCharge[cbc:ChargeIndicator=true()][cac:TaxCategory/cbc:ID = $category]) = 0 and      count(../../cac:AllowanceCharge[cbc:ChargeIndicator=false()][cac:TaxCategory/cbc:ID = $category]) = 0 and      (cbc:TaxableAmount =      sum(//cbc:LineExtensionAmount[../cac:Item/cac:ClassifiedTaxCategory/cbc:ID = $category]))))">[jp-br-co-05]-Tax category taxable amount (ibt-116) = Σ Invoice line net amount (ibt-131) – Document level allowance amount (ibt-092) + Document level charge amount (ibt-099).</assert>
    </rule>
    <rule context="/*/cac:TaxTotal/cac:TaxSubtotal/cac:TaxCategory[normalize-space(cbc:ID) = 'G'][cac:TaxScheme/normalize-space(upper-case(cbc:ID))='VAT']">
      <assert id="jp-e-01" flag="fatal" test="((exists(//cac:TaxCategory[cac:TaxScheme/normalize-space(upper-case(cbc:ID))='VAT']/cbc:ID[normalize-space(.) = 'E']) or exists(//cac:ClassifiedTaxCategory[cac:TaxScheme/normalize-space(upper-case(cbc:ID))='VAT']/cbc:ID[normalize-space(.) = 'E'])) and (count(cac:TaxTotal/cac:TaxSubtotal/cac:TaxCategory[cac:TaxScheme/normalize-space(upper-case(cbc:ID))='VAT']/cbc:ID[normalize-space(.) = 'E']) = 1)) or (not(//cac:TaxCategory[cac:TaxScheme/normalize-space(upper-case(cbc:ID))='VAT']/cbc:ID[normalize-space(.) = 'E']) and not(//cac:ClassifiedTaxCategory[cac:TaxScheme/normalize-space(upper-case(cbc:ID))='VAT']/cbc:ID[normalize-space(.) = 'E']))">[jp-e-01]-An Invoice that contains an Invoice line (ibg-25), a Document level allowance (ibg-20) or a Document level charge (ibg-21) where the tax category code (ibt-151, ibt-095, ibt-102) is “E (Exempt from tax)” shall contain exactly one “Tax breakdown” (ibg-23) with “Tax category code” (ibt-118) equal to “E”.</assert>
      <assert id="jp-e-09" flag="fatal" test="(xs:decimal(../cbc:TaxAmount) = 0)">[jp-e-09]-Tax category tax amount (ibt-117) shall be 0 (zero) if tax category code (ibt-118) equals to E (Exempt from tax).</assert>
    </rule>
    <rule context="cac:InvoiceLine/cac:Item/cac:ClassifiedTaxCategory[normalize-space(cbc:ID) = 'E'][cac:TaxScheme/normalize-space(upper-case(cbc:ID))='VAT'] | cac:CreditNoteLine/cac:Item/cac:ClassifiedTaxCategory[normalize-space(cbc:ID) = 'E'][cac:TaxScheme/normalize-space(upper-case(cbc:ID))='VAT']">
      <assert id="jp-e-05" flag="fatal" test="(xs:decimal(cbc:Percent) = 0)">[jp-e-05]-In an Invoice line (BG-25) where the Invoiced item tax category code (BT-151) is Exempt from tax, the Invoiced item tax rate (BT-152) shall be 0 (zero).</assert>
    </rule>
    <rule context="cac:AllowanceCharge[cbc:ChargeIndicator=false()]/cac:TaxCategory[normalize-space(cbc:ID)='E'][cac:TaxScheme/normalize-space(upper-case(cbc:ID))='VAT']">
      <assert id="jp-e-06" flag="fatal" test="(xs:decimal(cbc:Percent) = 0)">[jp-e-06]-In a Document level allowance (BG-20) where the Document level allowance tax category code (BT-95) is Exempt from tax, the Document level allowance tax rate (BT-96) shall be 0 (zero).</assert>
    </rule>
    <rule context="cac:AllowanceCharge[cbc:ChargeIndicator=true()]/cac:TaxCategory[normalize-space(cbc:ID)='E'][cac:TaxScheme/normalize-space(upper-case(cbc:ID))='VAT']">
      <assert id="jp-e-07" flag="fatal" test="(xs:decimal(cbc:Percent) = 0)">[jp-e-07]-In a Document level charge (BG-21) where the Document level charge tax category code (BT-102) is Exempt from tax, the Document level charge tax rate (BT-103) shall be 0 (zero).</assert>
    </rule>
    <rule context="/*/cac:TaxTotal/cac:TaxSubtotal/cac:TaxCategory[normalize-space(cbc:ID) = 'G'][cac:TaxScheme/normalize-space(upper-case(cbc:ID))='VAT']">
      <assert id="jp-g-01" flag="fatal" test="((exists(//cac:TaxCategory[cac:TaxScheme/normalize-space(upper-case(cbc:ID))='VAT']/cbc:ID[normalize-space(.) = 'G']) or exists(//cac:ClassifiedTaxCategory[cac:TaxScheme/normalize-space(upper-case(cbc:ID))='VAT']/cbc:ID[normalize-space(.) = 'G'])) and (count(cac:TaxTotal/cac:TaxSubtotal/cac:TaxCategory[cac:TaxScheme/normalize-space(upper-case(cbc:ID))='VAT']/cbc:ID[normalize-space(.) = 'G']) = 1)) or (not(//cac:TaxCategory[cac:TaxScheme/normalize-space(upper-case(cbc:ID))='VAT']/cbc:ID[normalize-space(.) = 'G']) and not(//cac:ClassifiedTaxCategory[cac:TaxScheme/normalize-space(upper-case(cbc:ID))='VAT']/cbc:ID[normalize-space(.) = 'G']))">[jp-g-01]-An Invoice that contains an invoice line (ibg-25) a Document level allowance (ibg-20) or a Document level charge (ibg-21)  where the tax category code (ibt-151) is “G (Free export item, tax not charged)” shall contain exactly one tax breakdown (ibg-23) with tax category code (ibt-118) equals to “G”.</assert>
      <assert id="jp-g-09" flag="fatal" test="(xs:decimal(../cbc:TaxAmount) = 0)">[jp-g-09]-Tax category tax amount (ibt-117) shall be 0 (zero) if tax category code (ibt-118) equals to “G (Free export item, tax not charged)”. </assert>
    </rule>
    <rule context="cac:InvoiceLine/cac:Item/cac:ClassifiedTaxCategory[normalize-space(cbc:ID) = 'G'][cac:TaxScheme/normalize-space(upper-case(cbc:ID))='VAT'] | cac:CreditNoteLine/cac:Item/cac:ClassifiedTaxCategory[normalize-space(cbc:ID) = 'G'][cac:TaxScheme/normalize-space(upper-case(cbc:ID))='VAT']">
      <assert id="jp-g-05" flag="fatal" test="(xs:decimal(cbc:Percent) = 0)">[jp-g-05]-In an invoice line (ibg-25) where the invoiced item tax category code (ibt-151) is “G (Free export item, tax not charged)” the invoiced item tax rate (ibt-152) shall be 0 (zero).</assert>
    </rule>
    <rule context="cac:AllowanceCharge[cbc:ChargeIndicator=false()]/cac:TaxCategory[normalize-space(cbc:ID)='G'][cac:TaxScheme/normalize-space(upper-case(cbc:ID))='VAT']">
      <assert id="jp-g-06" flag="fatal" test="(xs:decimal(cbc:Percent) = 0)">[jp-g-06]-In a document level allowance (ibg-20) where the Document level allowance tax category code (ibt-95) is “G (Free export item, tax not charged)” the document level allowance tax rate (ibt-96) shall be 0 (zero).</assert>
    </rule>
    <rule context="cac:AllowanceCharge[cbc:ChargeIndicator=true()]/cac:TaxCategory[normalize-space(cbc:ID)='G'][cac:TaxScheme/normalize-space(upper-case(cbc:ID))='VAT']">
      <assert id="jp-g-07" flag="fatal" test="(xs:decimal(cbc:Percent) = 0)">[jp-g-07]-In a document level charge (ibg-21) where the Document level charge tax category code (ibt-102) is “G (Free export item, tax not charged)” the document level charge tax rate (ibt-103) shall be 0 (zero).</assert>
    </rule>
    <rule context="/*/cac:TaxTotal/cac:TaxSubtotal/cac:TaxCategory[normalize-space(cbc:ID) = 'O'][cac:TaxScheme/normalize-space(upper-case(cbc:ID))='VAT']">
      <assert id="jp-o-01" flag="fatal" test="((exists(//cac:TaxCategory[cac:TaxScheme/normalize-space(upper-case(cbc:ID))='VAT']/cbc:ID[normalize-space(.) = 'O']) or exists(//cac:ClassifiedTaxCategory[cac:TaxScheme/normalize-space(upper-case(cbc:ID))='VAT']/cbc:ID[normalize-space(.) = 'O'])) and (count(cac:TaxTotal/cac:TaxSubtotal/cac:TaxCategory[cac:TaxScheme/normalize-space(upper-case(cbc:ID))='VAT']/cbc:ID[normalize-space(.) = 'O']) = 1)) or (not(//cac:TaxCategory[cac:TaxScheme/normalize-space(upper-case(cbc:ID))='VAT']/cbc:ID[normalize-space(.) = 'O']) and not(//cac:ClassifiedTaxCategory[cac:TaxScheme/normalize-space(upper-case(cbc:ID))='VAT']/cbc:ID[normalize-space(.) = 'O']))">[jp-o-01]-An Invoice that contains an invoice line (ibg-25), a document level allowance (ibg-20) and a document level charge (ibg-21) where the tax category code (ibt-151, ibt-095, ibt-102) is “O (Outside of scope of tax)” shall contain exactly one tax breakdown (ibg-23) with tax category code(ibt-118) equal to “O”.</assert>
      <assert id="jp-o-09" flag="fatal" test="(xs:decimal(../cbc:TaxAmount) = 0)">[jp-o-09]-Tax category tax amount (ibt-117) shall be 0 (zero) if tax category code (ibt-118) equals to “O (Outside of scope of tax)”.</assert>
    </rule>
    <rule context="cac:InvoiceLine/cac:Item/cac:ClassifiedTaxCategory[normalize-space(cbc:ID) = 'O'][cac:TaxScheme/normalize-space(upper-case(cbc:ID))='VAT'] | cac:CreditNoteLine/cac:Item/cac:ClassifiedTaxCategory[normalize-space(cbc:ID) = 'O'][cac:TaxScheme/normalize-space(upper-case(cbc:ID))='VAT']">
      <assert id="jp-o-05" flag="fatal" test="(not(cbc:Percent))">[jp-o-05]-In an invoice line (ibg-25) where the tax category code (ibt-151) is "O (Outside of scope of tax)" shall not contain an Invoiced item tax rate (BT-152).</assert>
    </rule>
    <rule context="cac:AllowanceCharge[cbc:ChargeIndicator=false()]/cac:TaxCategory[normalize-space(cbc:ID)='O'][cac:TaxScheme/normalize-space(upper-case(cbc:ID))='VAT']">
      <assert id="jp-o-06" flag="fatal" test="(not(cbc:Percent))">[jp-o-06]-In a document level allowance (ibg-20) where tax category code (ibt-95) is "O (Outside of scope of tax)" shall not contain a document level allowance tax rate (BT-96).</assert>
    </rule>
    <rule context="cac:AllowanceCharge[cbc:ChargeIndicator=true()]/cac:TaxCategory[normalize-space(cbc:ID)='O'][cac:TaxScheme/normalize-space(upper-case(cbc:ID))='VAT']">
      <assert id="jp-o-07" flag="fatal" test="(not(cbc:Percent))">[jp-o-07]-In a document level charge (ibg-21) where the tax category code (ibt-102) is "O (Outside of scope of tax)" shall not contain a Document level charge tax rate (BT-103).</assert>
    </rule>
  </pattern>
  <pattern id="Codesmodel">
    <rule flag="fatal" context="cbc:InvoiceTypeCode | cbc:CreditNoteTypeCode">
      <assert id="jp-cl-01" flag="fatal" test="(self::cbc:InvoiceTypeCode and ((not(contains(normalize-space(.), ' ')) and contains(' 80 82 84 380 383 386 393 395 575 623 780 ', concat(' ', normalize-space(.), ' '))))) or (self::cbc:CreditNoteTypeCode and ((not(contains(normalize-space(.), ' ')) and contains(' 81 83 381 396 532 ', concat(' ', normalize-space(.), ' ')))))">[jp-cl-01]-The document type code MUST be coded by the Japanese invoice related code lists of UNTDID 1001.</assert>
    </rule>
    <rule flag="fatal" context="cac:TaxCategory/cbc:ID | cac:ClassifiedTaxCategory/cbc:ID">
      <assert id="jp-cl-03" flag="fatal" test="( ( not(contains(normalize-space(.),' ')) and contains( ' AA S Z G O E ',concat(' ',normalize-space(.),' ') ) ) )">[jp-cl-03]- Japanese invoice tax categories MUST be coded using UNCL5305 code list</assert>
    </rule>
  </pattern>
  <pattern id="PeppolReused">
    <let name="MIMECODE" value="tokenize('application/pdf image/png image/jpeg text/csv application/vnd.openxmlformats-officedocument.spreadsheetml.sheet application/vnd.oasis.opendocument.spreadsheet', '\s')" />
    <let name="UNCL2005" value="tokenize('3 35 432', '\s')" />
    <let name="UNCL5189" value="tokenize('41 42 60 62 63 64 65 66 67 68 70 71 88 95 100 102 103 104 105', '\s')" />
    <let name="eaid" value="tokenize('0002 0007 0009 0037 0060 0088 0096 0097 0106 0130 0135 0142 0151 0183 0184 0190 0191 0192 0193 0195 0196 0198 0199 0200 0201 0202 0204 0208 0209 0210 0211 0212 0213 9901 9906 9907 9910 9913 9914 9915 9918 9919 9920 9922 9923 9924 9925 9926 9927 9928 9929 9930 9931 9932 9933 9934 9935 9936 9937 9938 9939 9940 9941 9942 9943 9944 9945 9946 9947 9948 9949 9950 9951 9952 9953 9955 9957', '\s')" />
    <let name="profile" value="if (/*/cbc:ProfileID and matches(normalize-space(/*/cbc:ProfileID), 'urn:fdc:peppol.eu:2017:poacc:billing:([0-9]{2}):1.0')) then         tokenize(normalize-space(/*/cbc:ProfileID), ':')[7]         else         'Unknown'" />
    <rule context="cbc:TaxCurrencyCode">
      <assert id="PEPPOL-EN16931-R005" flag="fatal" test="not(normalize-space(text()) = normalize-space(../cbc:DocumentCurrencyCode/text()))">Tax accounting currency code MUST be different from invoice currency code
            when provided.</assert>
    </rule>
    <rule context="cbc:IssueDate | cbc:DueDate | cbc:TaxPointDate | cbc:StartDate | cbc:EndDate | cbc:ActualDeliveryDate">
      <assert id="PEPPOL-EN16931-F001" flag="fatal" test="string-length(text()) = 10 and (string(.) castable as xs:date)">A
            date MUST be formatted YYYY-MM-DD.</assert>
    </rule>
    <rule context="cac:Price/cac:AllowanceCharge">
      <assert id="PEPPOL-EN16931-R044" flag="fatal" test="normalize-space(cbc:ChargeIndicator) = 'false'">Charge on price level is NOT allowed. Only value 'false' allowed.</assert>
      <assert id="PEPPOL-EN16931-R046" flag="fatal" test="not(cbc:BaseAmount) or xs:decimal(../cbc:PriceAmount) = xs:decimal(cbc:BaseAmount) - xs:decimal(cbc:Amount)">Item net price MUST equal (Gross price - item price discount) when gross
            price is provided.</assert>
    </rule>
    <rule context="cbc:EndpointID[@schemeID = '0088'] | cac:PartyIdentification/cbc:ID[@schemeID = '0088'] | cbc:CompanyID[@schemeID = '0088']">
      <assert id="PEPPOL-COMMON-R040" flag="fatal" test="matches(normalize-space(), '^[0-9]+$') and u:gln(normalize-space())">GLN must have a valid format according to GS1 rules.</assert>
    </rule>
    <rule context="cbc:EmbeddedDocumentBinaryObject[@mimeCode]">
      <assert id="PEPPOL-EN16931-CL001" flag="fatal" test="some $code in $MIMECODE                     satisfies @mimeCode = $code">Mime code must be according to
            subset of IANA code list.</assert>
    </rule>
    <rule context="cac:AllowanceCharge[cbc:ChargeIndicator = 'false']/cbc:AllowanceChargeReasonCode">
      <assert id="PEPPOL-EN16931-CL002" flag="fatal" test="some $code in $UNCL5189                     satisfies normalize-space(text()) = $code">Reason code MUST
            be according to subset of UNCL 5189 D.16B.</assert>
    </rule>
    <rule context="cac:InvoicePeriod/cbc:DescriptionCode">
      <assert id="PEPPOL-EN16931-CL006" flag="fatal" test="some $code in $UNCL2005                     satisfies normalize-space(text()) = $code">Invoice period
            description code must be according to UNCL 2005 D.16B.</assert>
    </rule>
    <rule context="cbc:EndpointID[@schemeID]">
      <assert id="PEPPOL-EN16931-CL008" flag="fatal" test="some $code in $eaid                     satisfies @schemeID = $code">Electronic address identifier
            scheme must be from the codelist "Electronic Address Identifier Scheme"</assert>
    </rule>
    <rule context="cbc:InvoiceTypeCode">
      <assert id="PEPPOL-EN16931-P0100" flag="fatal" test="$profile != '01' or (some $code in tokenize('380 383 386 393 82 80 84 395 575 623 780', '\s')                     satisfies normalize-space(text()) = $code)">Invoice type
            code MUST be set according to the profile.</assert>
    </rule>
    <rule context="cbc:CreditNoteTypeCode">
      <assert id="PEPPOL-EN16931-P0101" flag="fatal" test="$profile != '01' or (some $code in tokenize('381 396 81 83 532', '\s')                     satisfies normalize-space(text()) = $code)">Credit note
            type code MUST be set according to the profile.</assert>
    </rule>
    <rule context="cac:AccountingCustomerParty/cac:Party">
      <assert id="PEPPOL-EN16931-R010" flag="fatal" test="cbc:EndpointID">Buyer electronic address
            MUST be provided</assert>
    </rule>
    <rule context="cac:InvoiceLine | cac:CreditNoteLine">
      <assert id="PEPPOL-EN16931-R121" flag="fatal" test="not(cac:Price/cbc:BaseQuantity) or xs:decimal(cac:Price/cbc:BaseQuantity) > 0">Base quantity MUST be a positive number above zero.</assert>
    </rule>
    <rule context="cac:AccountingSupplierParty/cac:Party">
      <assert id="PEPPOL-EN16931-R020" flag="fatal" test="cbc:EndpointID">Seller electronic
            address MUST be provided</assert>
    </rule>
    <rule context="ubl:Invoice/cac:AllowanceCharge | ubl:Invoice/cac:InvoiceLine/cac:AllowanceCharge | cn:CreditNote/cac:AllowanceCharge | cn:CreditNote/cac:CreditNoteLine/cac:AllowanceCharge">
      <assert id="PEPPOL-EN16931-R043" flag="fatal" test="normalize-space(cbc:ChargeIndicator/text()) = 'true' or normalize-space(cbc:ChargeIndicator/text()) = 'false'">Allowance/charge ChargeIndicator value MUST equal 'true' or
            'false'</assert>
    </rule>
  </pattern>
</schema>
