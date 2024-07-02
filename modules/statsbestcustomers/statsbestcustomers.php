<?php
/*
* 2007-2016 PrestaShop
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
*  @copyright  2007-2016 PrestaShop SA
*  @license    http://opensource.org/licenses/afl-3.0.php  Academic Free License (AFL 3.0)
*  International Registered Trademark & Property of PrestaShop SA
*/

if (!defined('_PS_VERSION_')) {
    exit;
}

class StatsBestCustomers extends ModuleGrid
{
    private $html;
    private $query;
    private $columns;
    private $default_sort_column;
    private $default_sort_direction;
    private $empty_message;
    private $paging_message;

    public function __construct()
    {
        $this->name = 'statsbestcustomers';
        $this->tab = 'analytics_stats';
        $this->version = '1.5.2';
        $this->author = 'PrestaShop';
        $this->need_instance = 0;

        parent::__construct();

        $this->default_sort_column = 'totalMoneySpent';
        $this->default_sort_direction = 'DESC';
        $this->empty_message = $this->l('Empty recordset returned');
        $this->paging_message = sprintf($this->l('Displaying %1$s of %2$s'), '{0} - {1}', '{2}');

        $currency = new Currency(Configuration::get('PS_CURRENCY_DEFAULT'));

        $this->columns = array(
            array(
                'id' => 'firstname',
                'header' => $this->l('First name'),
                'dataIndex' => 'firstname',
                'align' => 'center'
            ),
            array(
                'id' => 'lastname',
                'header' => $this->l('Last name'),
                'dataIndex' => 'lastname',
                'align' => 'center'
            ),
            array(
                'id' => 'email',
                'header' => $this->l('Email'),
                'dataIndex' => 'email',
                'align' => 'center'
            ),
            array(
                'id' => 'totalVisits',
                'header' => $this->l('Visits'),
                'dataIndex' => 'totalVisits',
                'align' => 'center'
            ),
            array(
                'id' => 'totalMoneySpent',
                'header' => $this->l('Money spent').' ('.Tools::safeOutput($currency->iso_code).')',
                'dataIndex' => 'totalMoneySpent',
                'align' => 'center'
            ),
            array(
                'id' => 'totalValidOrders',
                'header' => $this->l('Valid orders'),
                'dataIndex' => 'totalValidOrders',
                'align' => 'center'
            ),
        );

        $this->displayName = $this->l('Best customers');
        $this->description = $this->l('Adds a list of the best customers to the Stats dashboard.');
        $this->ps_versions_compliancy = array('min' => '1.6', 'max' => '1.7.0.99');
    }

    public function install()
    {
        return (parent::install() && $this->registerHook('AdminStatsModules'));
    }

    public function hookAdminStatsModules($params)
    {
        $engine_params = array(
            'id' => 'id_customer',
            'title' => $this->displayName,
            'columns' => $this->columns,
            'defaultSortColumn' => $this->default_sort_column,
            'defaultSortDirection' => $this->default_sort_direction,
            'emptyMessage' => $this->empty_message,
            'pagingMessage' => $this->paging_message
        );

        if (Tools::getValue('export')) {
            $this->csvExport($engine_params);
        }

        $this->html = '
		<div class="panel-heading">
			'.$this->displayName.'
		</div>

		'.$this->engine($engine_params).'
		<a class="btn btn-default export-csv" href="'.Tools::safeOutput($_SERVER['REQUEST_URI'].'&export=').'1">
			<i class="icon-cloud-download"></i> '.$this->l('CSV Export').'
		</a>';

        return $this->html;
    }

    public function getData()
    {
        $currency = new Currency(Configuration::get('PS_CURRENCY_DEFAULT'));

        $this->query = 'SELECT SQL_CALC_FOUND_ROWS c.`id_customer`, c.`lastname`, c.`firstname`, c.`email`,
			COUNT(co.`id_connections`) as totalVisits,
			IFNULL((
				SELECT ROUND(SUM(IFNULL(op.`amount`, 0) / cu.conversion_rate), 2)
				FROM `'._DB_PREFIX_.'orders` o
				LEFT JOIN `'._DB_PREFIX_.'order_payment` op ON o.reference = op.order_reference
				LEFT JOIN `'._DB_PREFIX_.'currency` cu ON o.id_currency = cu.id_currency
				WHERE o.id_customer = c.id_customer
				AND o.invoice_date BETWEEN '.$this->getDate().'
				AND o.valid
			), 0) as totalMoneySpent,
			IFNULL((
				SELECT COUNT(*)
				FROM `'._DB_PREFIX_.'orders` o
				WHERE o.id_customer = c.id_customer
				AND o.invoice_date BETWEEN '.$this->getDate().'
				AND o.valid
			), 0) as totalValidOrders
		FROM `'._DB_PREFIX_.'customer` c
		LEFT JOIN `'._DB_PREFIX_.'guest` g ON c.`id_customer` = g.`id_customer`
		LEFT JOIN `'._DB_PREFIX_.'connections` co ON g.`id_guest` = co.`id_guest`
		WHERE co.date_add BETWEEN '.$this->getDate()
            .Shop::addSqlRestriction(Shop::SHARE_CUSTOMER, 'c').
            'GROUP BY c.`id_customer`, c.`lastname`, c.`firstname`, c.`email`';

        if (Validate::IsName($this->_sort)) {
            $this->query .= ' ORDER BY `'.bqSQL($this->_sort).'`';
            if (isset($this->_direction) && Validate::isSortDirection($this->_direction)) {
                $this->query .= ' '.$this->_direction;
            }
        }

        if (($this->_start === 0 || Validate::IsUnsignedInt($this->_start)) && Validate::IsUnsignedInt($this->_limit)) {
            $this->query .= ' LIMIT '.(int)$this->_start.', '.(int)$this->_limit;
        }

        $values = Db::getInstance(_PS_USE_SQL_SLAVE_)->executeS($this->query);
        $this->_totalCount = Db::getInstance(_PS_USE_SQL_SLAVE_)->getValue('SELECT FOUND_ROWS()');

        foreach ($values as &$value) {
            if (Tools::getValue('export') == false) {
                $value['email'] = '<a href="'.$this->context->link->getAdminLink('AdminCustomers').'&id_customer='.$value['id_customer'].'&updatecustomer" target="_blank">'.$value['email'].'</a>';
            }
            $value['totalMoneySpent'] = Tools::displayPrice($value['totalMoneySpent'], $currency);
        }

        $this->_values = $values;
    }
}
