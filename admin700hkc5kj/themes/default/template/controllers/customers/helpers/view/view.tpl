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

{extends file="helpers/view/view.tpl"}

{block name="override_tpl"}
<div id="container-customer">
	<div class="row">
		{*left*}
		<div class="col-lg-12">
			<div class="panel clearfix">
				<div class="panel-heading">
					<i class="icon-user"></i>
					{$customer->firstname}
					{$customer->lastname}
					[{$customer->id|string_format:"%06d"}]
					-
					<a href="mailto:{$customer->email}"><i class="icon-envelope"></i>
						{$customer->email}
					</a>
					<div class="panel-heading-action">
						<a class="btn btn-default" href="{$current|escape:'html':'UTF-8'}&amp;updatecustomer&amp;id_customer={$customer->id|intval}&amp;token={$token|escape:'html':'UTF-8'}&amp;back={$smarty.server.REQUEST_URI|urlencode}">
							<i class="icon-edit"></i>
							{l s='Edit'}
						</a>
					</div>
				</div>
				<div class="form-horizontal">
					<div class="row">
						<label class="control-label col-lg-3">{l s='Social Title'}</label>
						<div class="col-lg-9">
							<p class="form-control-static">{if $gender->name}{$gender->name}{else}{l s='Unknown'}{/if}</p>
						</div>
					</div>
					<div class="row">
						<label class="control-label col-lg-3">{l s='Age'}</label>
						<div class="col-lg-9">
							<p class="form-control-static">
								{if isset($customer->birthday) && $customer->birthday != '0000-00-00'}
									{l s='%1$d years old (birth date: %2$s)' sprintf=[$customer_stats['age'], $customer_birthday]}
								{else}
									{l s='Unknown'}
								{/if}
							</p>
						</div>
					</div>
					<div class="row">
						<label class="control-label col-lg-3">{l s='Registration Date'}</label>
						<div class="col-lg-9">
							<p class="form-control-static">{$registration_date}</p>
						</div>
					</div>

					{if $count_better_customers != '-'}
						<div class="row">
							<label class="control-label col-lg-3">{l s='Best Customer Rank'}</label>
							<div class="col-lg-9">
								<p class="form-control-static">{$count_better_customers}</p>
							</div>
						</div>
					{/if}
					{if $shop_is_feature_active}
						<div class="row">
							<label class="control-label col-lg-3">{l s='Shop'}</label>
							<div class="col-lg-9">
								<p class="form-control-static">{$name_shop}</p>
							</div>
						</div>
					{/if}

					<div class="row">
						<label class="control-label col-lg-3">{l s='Latest Update'}</label>
						<div class="col-lg-9">
							<p class="form-control-static">{$last_update}</p>
						</div>
					</div>
					<div class="row">
						<label class="control-label col-lg-3">{l s='Status'}</label>
						<div class="col-lg-9">
							<p class="form-control-static">
								{if $customer->active}
									<span class="label label-success">
										<i class="icon-check"></i>
										{l s='Active'}
									</span>
								{else}
									<span class="label label-danger">
										<i class="icon-remove"></i>
										{l s='Inactive'}
									</span>
								{/if}
							</p>
						</div>
					</div>
				</div>
				{if $customer->isGuest()}
					{l s='This customer is registered as a Guest.'}
					{if !$customer_exists}
					<form method="post" action="index.php?tab=AdminCustomers&amp;id_customer={$customer->id|intval}&amp;token={getAdminToken tab='AdminCustomers'}">
						<input type="hidden" name="id_lang" value="{$id_lang}" />
						<p class="text-center">
							<input class="button" type="submit" name="submitGuestToCustomer" value="{l s='Transform to a customer account'}" />
						</p>
						{l s='This feature generates a random password before sending an email to your customer.'}
					</form>
					{else}
					<p class="text-muted text-center">
						{l s='A registered customer account using the defined email address already exists. '}
					</p>
					{/if}
				{/if}
			</div>
			<div class="panel">
				<div class="panel-heading">
					<i class="icon-file"></i> {l s='Orders'} <span class="badge">{count($orders)}</span>
				</div>
				{if $orders AND count($orders)}
					{assign var=count_ok value=count($orders_ok)}
					{assign var=count_ko value=count($orders_ko)}
					<div class="panel">
						<div class="row">
							<div class="col-lg-6">
								<i class="icon-ok-circle icon-big"></i>
								{l s='Valid orders:'}
								<span class="label label-success">{$count_ok}</span>
								{l s='for a total amount of %s' sprintf=$total_ok}
							</div>
							<div class="col-lg-6">
								<i class="icon-exclamation-sign icon-big"></i>
								{l s='Invalid orders:'}
								<span class="label label-danger">{$count_ko}</span>
							</div>
						</div>
					</div>

					{if $count_ok}
						<table class="table">
							<thead>
								<tr>
									<th class="center"><span class="title_box ">{l s='ID'}</span></th>
									<th><span class="title_box">{l s='Date'}</span></th>
									<th><span class="title_box">{l s='Payment'}</span></th>
									<th><span class="title_box">{l s='Status'}</span></th>
									<th><span class="title_box">{l s='Products'}</span></th>
									<th><span class="title_box ">{l s='Total spent'}</span></th>
									<th></th>
								</tr>
							</thead>
							<tbody>
							{foreach $orders_ok AS $key => $order}
								<tr onclick="document.location = '?tab=AdminOrders&amp;id_order={$order['id_order']|intval}&amp;vieworder&amp;token={getAdminToken tab='AdminOrders'}'">
									<td>{$order['id_order']}</td>
									<td>{dateFormat date=$order['date_add'] full=0}</td>
									<td>{$order['payment']}</td>
									<td>{$order['order_state']}</td>
									<td>{$order['nb_products']}</td>
									<td>{$order['total_paid_real']}</td>
									<td>
										<a class="btn btn-default" href="?tab=AdminOrders&amp;id_order={$order['id_order']|intval}&amp;vieworder&amp;token={getAdminToken tab='AdminOrders'}">
											<i class='icon-search'></i> {l s='View'}
										</a>
									</td>
								</tr>
							{/foreach}
							</tbody>
						</table>
					{/if}

					{if $count_ko}
						<table class="table">
							<thead>
								<tr>
									<th><span class="title_box ">{l s='ID'}</span></th>
									<th><span class="title_box ">{l s='Date'}</span></th>
									<th><span class="title_box ">{l s='Payment'}</span></th>
									<th><span class="title_box ">{l s='Status'}</span></th>
									<th><span class="title_box ">{l s='Products'}</span></th>
									<th><span class="title_box ">{l s='Total spent'}</span></th>
								</tr>
							</thead>
							<tbody>
								{foreach $orders_ko AS $key => $order}
								<tr onclick="document.location = '?tab=AdminOrders&amp;id_order={$order['id_order']|intval}&amp;vieworder&amp;token={getAdminToken tab='AdminOrders'}'">
									<td>{$order['id_order']}</td>
									<td><a href="?tab=AdminOrders&amp;id_order={$order['id_order']}&amp;vieworder&amp;token={getAdminToken tab='AdminOrders'}">{dateFormat date=$order['date_add'] full=0}</a></td>
									<td>{$order['payment']}</td>
									<td>{$order['order_state']}</td>
									<td>{$order['nb_products']}</td>
									<td>{$order['total_paid_real']}</td>
								</tr>
								{/foreach}
							</tbody>
						</table>
					{/if}
				{else}
				<p class="text-muted text-center">
					{l s='%1$s %2$s has not placed any orders yet' sprintf=[$customer->firstname, $customer->lastname]}
				</p>
				{/if}
			</div>

			<div class="panel">
				<div class="panel-heading">
					<i class="icon-shopping-cart"></i> {l s='Carts'} <span class="badge">{count($carts)}</span>
				</div>
				{if $carts AND count($carts)}
					<table class="table">
						<thead>
							<tr>
								<th><span class="title_box ">{l s='ID'}</span></th>
								<th><span class="title_box ">{l s='Date'}</span></th>
								<th><span class="title_box ">{l s='Carrier'}</span></th>
								<th><span class="title_box ">{l s='Total'}</span></th>
							</tr>
						</thead>
						<tbody>
						{foreach $carts AS $key => $cart}
							<tr onclick="document.location = '?tab=AdminCarts&amp;id_cart={$cart['id_cart']|intval}&amp;viewcart&amp;token={getAdminToken tab='AdminCarts'}'">
								<td>{$cart['id_cart']}</td>
								<td>
									<a href="index.php?tab=AdminCarts&amp;id_cart={$cart['id_cart']}&amp;viewcart&amp;token={getAdminToken tab='AdminCarts'}">
										{dateFormat date=$cart['date_upd'] full=0}
									</a>
								</td>
								<td>{$cart['name']}</td>
								<td>{$cart['total_price']}</td>
							</tr>
						{/foreach}
						</tbody>
					</table>
				{else}
				<p class="text-muted text-center">
					{l s='No cart is available'}
				</p>
				{/if}
			</div>
			{if $products AND count($products)}
			<div class="panel">
				<div class="panel-heading">
					<i class="icon-archive"></i> {l s='Purchased products'} <span class="badge">{count($products)}</span>
				</div>
				<table class="table">
					<thead>
						<tr>
							<th><span class="title_box">{l s='Date'}</span></th>
							<th><span class="title_box">{l s='Name'}</span></th>
							<th><span class="title_box">{l s='Quantity'}</span></th>
						</tr>
					</thead>
					<tbody>
						{foreach $products AS $key => $product}
						<tr onclick="document.location = '?tab=AdminOrders&amp;id_order={$product['id_order']|intval}&amp;vieworder&amp;token={getAdminToken tab='AdminOrders'}'">
							<td>{dateFormat date=$product['date_add'] full=0}</td>
							<td>
								<a href="?tab=AdminOrders&amp;id_order={$product['id_order']}&amp;vieworder&amp;token={getAdminToken tab='AdminOrders'}">
									{$product['product_name']}
								</a>
							</td>
							<td>{$product['product_quantity']}</td>
						</tr>
						{/foreach}
					</tbody>
				</table>
			</div>
			{/if}

		</div>

	</div>

	<div class="row">
		<div class="col-lg-6">

		</div>
		<div class="col-lg-6">
			{if count($referrers)}
			<div class="panel">
				<div class="panel-heading">
					<i class="icon-share-alt"></i> {l s='Referrers'}
				</div>
				<table class="table">
					<thead>
						<tr>
							<th><span class="title_box ">{l s='Date'}</span></th>
							<th><span class="title_box ">{l s='Name'}</span></th>
							{if $shop_is_feature_active}<th>{l s='Shop'}</th>{/if}
						</tr>
					</thead>
					<tbody>
						{foreach $referrers as $referrer}
						<tr>
							<td>{dateFormat date=$order['date_add'] full=0}</td>
							<td>{$referrer['name']}</td>
							{if $shop_is_feature_active}<td>{$referrer['shop_name']}</td>{/if}
						</tr>
						{/foreach}
					</tbody>
				</table>
			</div>
			{/if}
		</div>
	</div>

	<div class="row">

	</div>
</div>
{/block}
