{*
* 2007-2017 PrestaShop
*
* NOTICE OF LICENSE
*
* This source file is subject to the Academic Free License (AFL 3.0)
* that is bundled with this package in the file LICENSE.txt.
* It is also available through the world-wide-web at this URL:
* http://opensource.org/licenses/afl-3.0.php
* If you did not receive a copy of the license and are unable to
* obtain it through the world-wide-web, please send an email
* to license@prestashop.com so we can send you a copy immediately.
*
* DISCLAIMER
*
* Do not edit or add to this file if you wish to upgrade PrestaShop to newer
* versions in the future. If you wish to customize PrestaShop for your
* needs please refer to http://www.prestashop.com for more information.
*
*  @author PrestaShop SA <contact@prestashop.com>
*  @copyright  2007-2017 PrestaShop SA
*  @license    http://opensource.org/licenses/afl-3.0.php  Academic Free License (AFL 3.0)
*  International Registered Trademark & Property of PrestaShop SA
*}

<script type="text/javascript">
var Customer = new Object();
var product_url = '{$link->getAdminLink('AdminProducts', true)|addslashes}';
var ecotax_tax_excl = parseFloat({$ecotax_tax_excl});
var priceDisplayPrecision = {$smarty.const._PS_PRICE_DISPLAY_PRECISION_|intval};

$(document).ready(function () {
	Customer = {
		"hiddenField": jQuery('#id_customer'),
		"field": jQuery('#customer'),
		"container": jQuery('#customers'),
		"loader": jQuery('#customerLoader'),
		"init": function() {
			jQuery(Customer.field).typeWatch({
				"captureLength": 1,
				"highlight": true,
				"wait": 50,
				"callback": Customer.search
			}).focus(Customer.placeholderIn).blur(Customer.placeholderOut);
		},
		"placeholderIn": function() {
			if (this.value == '{l s='All customers'}') {
				this.value = '';
			}
		},
		"placeholderOut": function() {
			if (this.value == '') {
				this.value = '{l s='All customers'}';
			}
		},
		"search": function()
		{
			Customer.showLoader();
			jQuery.ajax({
				"type": "POST",
				"url": "{$link->getAdminLink('AdminCustomers')|addslashes}",
				"async": true,
				"dataType": "json",
				"data": {
					"ajax": "1",
					"token": "{getAdminToken tab='AdminCustomers'}",
					"tab": "AdminCustomers",
					"action": "searchCustomers",
					"customer_search": Customer.field.val()
				},
				"success": Customer.success
			});
		},
		"success": function(result)
		{
			if(result.found) {
				var html = '<ul class="list-unstyled">';
				jQuery.each(result.customers, function() {
					html += '<li><a class="fancybox" href="{$link->getAdminLink('AdminCustomers')}&id_customer='+this.id_customer+'&viewcustomer&liteDisplaying=1">'+this.firstname+' '+this.lastname+'</a>'+(this.birthday ? ' - '+this.birthday:'');
					html += ' - '+this.email;
					html += '<a onclick="Customer.select('+this.id_customer+', \''+this.firstname+' '+this.lastname+'\'); return false;" href="#" class="btn btn-default">{l s='Choose'}</a></li>';
				});
				html += '</ul>';
			}
			else
				html = '<div class="alert alert-warning">{l s='No customers found'}</div>';
			Customer.hideLoader();
			Customer.container.html(html);
			jQuery('.fancybox', Customer.container).fancybox();
		},
		"select": function(id_customer, fullname)
		{
			Customer.hiddenField.val(id_customer);
			Customer.field.val(fullname);
			Customer.container.empty();
			return false;
		},
		"showLoader": function() {
			Customer.loader.fadeIn();
		},
		"hideLoader": function() {
			Customer.loader.fadeOut();
		}
	};
	Customer.init();
});
</script>
{capture assign=priceDisplayPrecisionFormat}{'%.'|cat:$smarty.const._PS_PRICE_DISPLAY_PRECISION_|cat:'f'}{/capture}
<div id="product-prices" class="panel product-tab">
	<input type="hidden" name="submitted_tabs[]" value="Prices" />
	<h3>{l s='Room type price'}</h3>
	<!--
	<div class="alert alert-info" {if !$country_display_tax_label || $tax_exclude_taxe_option}style="display:none;"{/if}>
		{l s='You must enter either the pre-tax retail price, or the retail price with tax. The input field will be automatically calculated.'}
	</div>
	-->
	{include file="controllers/products/multishop/check_fields.tpl" product_tab="Prices"}
	<div class="form-group">
		<div class="col-lg-1"><span class="pull-right">{include file="controllers/products/multishop/checkbox.tpl" field="wholesale_price" type="default"}</span></div>
		<label class="control-label col-lg-2" for="wholesale_price">
			<span class="label-tooltip" data-toggle="tooltip" title="{l s='The operating cost is the expense related to the operation of the room type. Do not include the tax.'}">{if !$country_display_tax_label || $tax_exclude_taxe_option}{l s='Operating cost'}{else}{l s='Pre-tax operating cost'}{/if}</span>
		</label>
		<div class="col-lg-2">
			<div class="input-group">
				<span class="input-group-addon">{$currency->prefix}{$currency->suffix}</span>
				<input maxlength="27" name="wholesale_price" id="wholesale_price" type="text" value="{{toolsConvertPrice price=$product->wholesale_price}|string_format:$priceDisplayPrecisionFormat}" onchange="this.value = this.value.replace(/,/g, '.');" />
			</div>
			{if isset($pack) && $pack->isPack($product->id)}<p class="help-block">{l s='The sum of wholesale prices of the room types in the pack is %s%s%s' sprintf=[$currency->prefix,{toolsConvertPrice price=$pack->noPackWholesalePrice($product->id)|string_format:$priceDisplayPrecisionFormat},$currency->suffix]}</p>{/if}
		</div>
	</div>
	<div class="form-group">
		<div class="col-lg-1"><span class="pull-right">{include file="controllers/products/multishop/checkbox.tpl" field="price" type="price"}</span></div>
		<label class="control-label col-lg-2" for="priceTE">
			<span class="label-tooltip" data-toggle="tooltip" title="{l s='The pre-tax retail price is the price for which you intend sell this room type to your customers. It should be higher than the pre-tax operating cost: the difference between the two will be your margin.'}">{if !$country_display_tax_label || $tax_exclude_taxe_option}{l s='Retail price'}{else}{l s='Pre-tax retail price'}{/if}</span>
		</label>
		<div class="col-lg-2">
			<div class="input-group">
				<span class="input-group-addon">{$currency->prefix}{$currency->suffix}</span>
				<input type="hidden" id="priceTEReal" name="price" value="{toolsConvertPrice price=$product->price}"/>
				<input size="11" maxlength="27" id="priceTE" name="price_displayed" type="text" value="{{toolsConvertPrice price=$product->price}|string_format:'%.6f'}" onchange="noComma('priceTE'); $('#priceTEReal').val(this.value);" onkeyup="$('#priceType').val('TE'); $('#priceTEReal').val(this.value.replace(/,/g, '.')); if (isArrowKey(event)) return; calcPriceTI();" />
			</div>
		</div>
	</div>
	<div class="form-group">
		<div class="col-lg-1"><span class="pull-right">{include file="controllers/products/multishop/checkbox.tpl" field="id_tax_rules_group" type="default"}</span></div>
		<label class="control-label col-lg-2" for="id_tax_rules_group">
			{l s='Tax rule:'}
		</label>
		<div class="col-lg-8">
			<script type="text/javascript">
				noTax = {if $tax_exclude_taxe_option}true{else}false{/if};
				taxesArray = new Array();
				{foreach $taxesRatesByGroup as $tax_by_group}
					taxesArray[{$tax_by_group.id_tax_rules_group}] = {$tax_by_group|json_encode};
				{/foreach}
				ecotaxTaxRate = {$ecotaxTaxRate / 100};
			</script>
			<div class="row">
				<div class="col-lg-6">
					<select onchange="javascript:calcPrice(); {*unitPriceWithTax('unit');*}" name="id_tax_rules_group" id="id_tax_rules_group" {if $tax_exclude_taxe_option}disabled="disabled"{/if} >
						<option value="0">{l s='No Tax'}</option>
					{foreach from=$tax_rules_groups item=tax_rules_group}
						<option value="{$tax_rules_group.id_tax_rules_group}" {if $product->getIdTaxRulesGroup() == $tax_rules_group.id_tax_rules_group}selected="selected"{/if} >
					{$tax_rules_group['name']|htmlentitiesUTF8}
						</option>
					{/foreach}
					</select>
				</div>
				<!--
				<div class="col-lg-2">
					<a class="btn btn-link confirm_leave" href="{$link->getAdminLink('AdminTaxRulesGroup')|escape:'html':'UTF-8'}&amp;addtax_rules_group&amp;id_product={$product->id}"{if $tax_exclude_taxe_option} disabled="disabled"{/if}>
						<i class="icon-plus-sign"></i> {l s='Create new tax'} <i class="icon-external-link-sign"></i>
					</a>
				</div>
				-->
			</div>
		</div>
	</div>
	{if $tax_exclude_taxe_option}
	<div class="form-group">
		<div class="col-lg-9 col-lg-offset-3">
			<div class="alert">
				{l s='Taxes are currently disabled:'}
				<a href="{$link->getAdminLink('AdminTaxes')|escape:'html':'UTF-8'}">{l s='Click here to open the Taxes configuration page.'}</a>
				<input type="hidden" value="{$product->getIdTaxRulesGroup()}" name="id_tax_rules_group" />
			</div>
		</div>
	</div>
	{/if}
	<div class="form-group" {if !$ps_use_ecotax} style="display:none;"{/if}>
		<div class="col-lg-1"><span class="pull-right">{include file="controllers/products/multishop/checkbox.tpl" field="ecotax" type="default"}</span></div>
		<label class="control-label col-lg-2" for="ecotax">
			<span class="label-tooltip" data-toggle="tooltip" title="{l s='The ecotax is a local set of taxes intended to "promote ecologically sustainable activities via economic incentives". It is already included in retail price: the higher this ecotax is, the lower your margin will be.'}">{l s='Ecotax (tax incl.)'}</span>
		</label>
		<div class="input-group col-lg-2">
			<span class="input-group-addon">{$currency->prefix}{$currency->suffix}</span>
			<input maxlength="27" id="ecotax" name="ecotax" type="text" value="{$product->ecotax|string_format:$priceDisplayPrecisionFormat}" onkeyup="$('#priceType').val('TI');if (isArrowKey(event))return; calcPriceTE(); this.value = this.value.replace(/,/g, '.'); if (parseInt(this.value) > getE('priceTE').value) this.value = getE('priceTE').value; if (isNaN(this.value)) this.value = 0;" />
		</div>
	</div>
	<div class="form-group" {if !$country_display_tax_label || $tax_exclude_taxe_option}style="display:none;"{/if} >
		<label class="control-label col-lg-3" for="priceTI">{l s='Retail price with tax'}</label>
		<div class="input-group col-lg-2">
			<span class="input-group-addon">{$currency->prefix}{$currency->suffix}</span>
			<input id="priceType" name="priceType" type="hidden" value="TE" />
			<input id="priceTI" name="priceTI" type="text" value="" onchange="noComma('priceTI');" maxlength="27" onkeyup="$('#priceType').val('TI');if (isArrowKey(event)) return;  calcPriceTE();" />
		</div>
		{if isset($pack) && $pack->isPack($product->id)}<p class="col-lg-9 col-lg-offset-3 help-block">{l s='The sum of prices of the room types in the pack is %s%s%s' sprintf=[$currency->prefix,{toolsConvertPrice price=$pack->noPackPrice($product->id)|string_format:$priceDisplayPrecisionFormat},$currency->suffix]}</p>{/if}
	</div>
	{* As no use in QloApps currently so commented *}
	{* <div class="form-group">
		<div class="col-lg-1"><span class="pull-right">{include file="controllers/products/multishop/checkbox.tpl" field="unit_price" type="unit_price"}</span></div>
		<label class="control-label col-lg-2" for="unit_price">
			<span class="label-tooltip" data-toggle="tooltip" title="{l s='When selling a pack of items, you can indicate the unit price for each item of the pack. For instance, "per bottle" or "per pound".'}">{l s='Unit price (tax excl.)'}</span>
		</label>
		<div class="col-lg-4">
			<div class="input-group">
				<span class="input-group-addon">{$currency->prefix}{$currency->suffix}</span>
				<input id="unit_price" name="unit_price" type="text" value="{$unit_price|string_format:'%.6f'}" maxlength="27" onkeyup="if (isArrowKey(event)) return ;this.value = this.value.replace(/,/g, '.'); unitPriceWithTax('unit');"/>
				<span class="input-group-addon">{l s='per'}</span>
				<input id="unity" name="unity" type="text" value="{$product->unity|htmlentitiesUTF8}"  maxlength="255" onkeyup="if (isArrowKey(event)) return ;unitySecond();" onchange="unitySecond();"/>
			</div>
		</div>
	</div> *}
	{if isset($product->unity) && $product->unity}
	<div class="form-group">
		<div class="col-lg-9 col-lg-offset-3">
			<div class="alert alert-warning">
				<span>{l s='or'}
					{$currency->prefix}<span id="unit_price_with_tax">0.00</span>{$currency->suffix}
					{l s='per'} <span id="unity_second">{$product->unity}</span>{if $ps_tax && $country_display_tax_label} {l s='(tax incl.)'}{/if}
				</span>
			</div>
		</div>
	</div>
	{/if}
	<!--
	<div class="form-group">
		<div class="col-lg-1"><span class="pull-right">{include file="controllers/products/multishop/checkbox.tpl" field="on_sale" type="default"}</span></div>
		<label class="control-label col-lg-2" for="on_sale">&nbsp;</label>
		<div class="col-lg-9">
			<div class="checkbox">
				<label class="control-label" for="on_sale" >
					<input type="checkbox" name="on_sale" id="on_sale" {if $product->on_sale}checked="checked"{/if} value="1" />
					{l s='Display the "on sale" icon on the room type page, and in the text found within the room type listing.'}
				</label>
			</div>
		</div>
	</div>
	-->

	<div class="form-group">
		<div class="col-lg-9 col-lg-offset-3">
			<div class="alert alert-warning">
				<strong>{l s='Final retail price:'}</strong>
				<span>
					{$currency->prefix}
					<span id="finalPrice" >0.00</span>
					{$currency->suffix}
					<span{if !$ps_tax} style="display:none;"{/if}> ({l s='tax incl.'})</span>
				</span>
				<span{if !$ps_tax} style="display:none;"{/if} >
				{if $country_display_tax_label}
					/
				{/if}
					{$currency->prefix}
				<span id="finalPriceWithoutTax"></span>
					{$currency->suffix}
					{if $country_display_tax_label}({l s='tax excl.'}){/if}
				</span>
			</div>
		</div>
	</div>

	<!-- by webkul -->
	{if $WK_ALLOW_ADVANCED_PAYMENT}
		<div class="form-group">
			<div class="col-lg-1"><span class="pull-right">{include file="controllers/products/multishop/checkbox.tpl" field="price" type="price"}</span></div>
			<label class="control-label col-sm-2">
				<input type="hidden" name="id_adv_pmt" {if isset($adv_pay_dtl)}value="{$adv_pay_dtl['id']}"{/if}>
				<span class="label-tooltip" data-toggle="tooltip" title="{l s='If Disabled, Advance payment will not apply on this room type.'}">
					{l s='Allow Advance Payment'}
				</span>
			</label>
			<div class="col-lg-9">
				<span class="switch prestashop-switch fixed-width-lg">
					<input type="radio" value="1" id="adv_payment_active_on" name="adv_payment_active" class="adv_payment_active" {if ((isset($adv_pay_dtl) && $adv_pay_dtl['active']) || !isset($adv_pay_dtl))}checked="checked"{/if}>
					<label for="adv_payment_active_on">{l s='Yes'}</label>
					<input type="radio" value="0" id="adv_payment_active_off" name="adv_payment_active" class="adv_payment_active" {if (isset($adv_pay_dtl) && !$adv_pay_dtl['active'])}checked="checked"{/if}>
					<label for="adv_payment_active_off">{l s='No'}</label>
					<a class="slide-button btn"></a>
				</span>
			</div>
		</div>
		<div class="adv_payment_field">
			<div class="form-group">
				<div class="col-lg-1"><span class="pull-right">{include file="controllers/products/multishop/checkbox.tpl" field="price" type="price"}</span></div>
				<label class="control-label col-sm-2">
					<span class="label-tooltip" data-toggle="tooltip" title="{l s='If disabled, Advance Payment for the room type will be calculated By Global Advance payment settings.'}">
						{l s='Apply Room Type Advance Payment Setting.'}
					</span>
				</label>
				<div class="col-lg-9">
					<span class="switch prestashop-switch fixed-width-lg">
						<input type="radio" value="1" id="cal_from_on" name="cal_from" {if (isset($adv_pay_dtl) && $adv_pay_dtl['calculate_from'])}checked="checked"{/if}>
						<label for="cal_from_on">{l s='Yes'}</label>
						<input type="radio" value="0" id="cal_from_off" name="cal_from" {if ((isset($adv_pay_dtl) && !$adv_pay_dtl['calculate_from']) || !isset($adv_pay_dtl))}checked="checked"{/if}>
						<label for="cal_from_off">{l s='No'}</label>
						<a class="slide-button btn"></a>
					</span>
				</div>
			</div>
			<div class="room_type_adv_payment_field">
				<div class="form-group">
					<div class="col-lg-1"><span class="pull-right">{include file="controllers/products/multishop/checkbox.tpl" field="price" type="price"}</span></div>
					<label class="control-label col-sm-2">{l s='Payment type'}</label>
					<div class="col-lg-9">
						<div class="radio">
							<label for="percent_type">
								<input type="radio" name="payment_type" class="payment_type" value="1" {if ((isset($adv_pay_dtl) && ($adv_pay_dtl['payment_type'] == 1)) || !isset($adv_pay_dtl) || !$adv_pay_dtl['payment_type'])}checked="checked"{/if}>
								{l s='Percent (%) '}
							</label>
						</div>
						<div class="radio">
							<label for="fixed_type">
								<input type="radio" name="payment_type" class="payment_type" value="2" {if isset($adv_pay_dtl) && ($adv_pay_dtl['payment_type'] == 2)}checked="checked"{/if}>
								{l s='Amount'}
							</label>
						</div>
					</div>
				</div>
				<div class="form-group">
					<div class="col-lg-1"><span class="pull-right">{include file="controllers/products/multishop/checkbox.tpl" field="price" type="price"}</span></div>
					<div class="col-lg-11">

						<div class="row" id="type_percent">
							<label class="control-label col-sm-2">{l s='Value'}</label>
							<div class="col-sm-4 col-lg-3">
								<div class="input-group">
									<span class="input-group-addon">%</span>
									<input type="text" value="{if isset($adv_pay_dtl) && ($adv_pay_dtl['payment_type'] == 1)}{$adv_pay_dtl['value']}{/if}" name="adv_pay_percent" />
								</div>
							</div>
						</div>

						<div class="row" id="type_amount">
							<label class="control-label col-sm-2">{l s='Amount'}</label>
							<div class="col-sm-9">
								<div class="row">
									<div class="col-sm-4 col-lg-3">
										<div class="input-group">
											<span class="input-group-addon">{$currency->prefix}{$currency->suffix}</span>
											<input name="adv_pay_amount" type="text" value="{if isset($adv_pay_dtl) && ($adv_pay_dtl['payment_type'] == 2)}{{toolsConvertPrice price=$adv_pay_dtl['value']}|string_format:'%.6f'}{/if}"/>
										</div>
									</div>
								</div>
								<div class="help-block">
									{l s='If final price of the room type is less than advance payment amount for the customer then customer will pay the final(lesser) price of the room type.'}
								</div>
							</div>
						</div>

					</div>
				</div>
				<div class="form-group">
				<div class="col-lg-1"><span class="pull-right">{include file="controllers/products/multishop/checkbox.tpl" field="price" type="price"}</span></div>
				<label class="control-label col-sm-2">
					<span class="label-tooltip" data-toggle="tooltip" title="{l s='If Enable, customer will pay : (Advanced payment price + tax) and if Disabled, customer will only pay advanced payment price'}">
						{l s='Include tax'}
					</span>
				</label>
				<div class="col-lg-9">
					<span class="switch prestashop-switch fixed-width-lg">
						<input type="radio" value="1" id="adv_tax_include_on" name="adv_tax_include" {if (isset($adv_pay_dtl) && $adv_pay_dtl['tax_include']) || !isset($adv_pay_dtl)}checked="checked"{/if}>
						<label for="adv_tax_include_on">{l s='Yes'}</label>
						<input type="radio" value="0" id="adv_tax_include_off" name="adv_tax_include" {if isset($adv_pay_dtl) && !$adv_pay_dtl['tax_include']}checked="checked"{/if}>
						<label for="adv_tax_include_off">{l s='No'}</label>
						<a class="slide-button btn"></a>
					</span>
				</div>
				</div>
			</div>
		</div>

	{/if}

	<div class="panel-footer">
		<a href="{$link->getAdminLink('AdminProducts')|escape:'html':'UTF-8'}{if isset($smarty.request.page) && $smarty.request.page > 1}&amp;submitFilterproduct={$smarty.request.page|intval}{/if}" class="btn btn-default"><i class="process-icon-cancel"></i> {l s='Cancel'}</a>
		<button type="submit" name="submitAddproduct" class="btn btn-default pull-right" disabled="disabled"><i class="process-icon-loading"></i> {l s='Save'}</button>
		<button type="submit" name="submitAddproductAndStay" class="btn btn-default pull-right" disabled="disabled"><i class="process-icon-loading"></i> {l s='Save and stay'}</button>
	</div>
</div>



