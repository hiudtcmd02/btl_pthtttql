<?php
/*
* 2007-2017 PrestaShop
*
* NOTICE OF LICENSE
*
* This source file is subject to the Open Software License (OSL 3.0)
* that is bundled with this package in the file LICENSE.txt.
* It is also available through the world-wide-web at this URL:
* http://opensource.org/licenses/osl-3.0.php
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
*  @license    http://opensource.org/licenses/osl-3.0.php  Open Software License (OSL 3.0)
*  International Registered Trademark & Property of PrestaShop SA
*/

class AdminInvoicesControllerCore extends AdminController
{
    public function __construct()
    {
        $this->bootstrap = true;
        $this->table = 'invoice';

        parent::__construct();

    }

    public function initFormByDate()
    {
        $this->fields_form = array(
            'legend' => array(
                'title' => $this->l('By date'),
                'icon' => 'icon-calendar'
            ),
            'input' => array(
                array(
                    'type' => 'date',
                    'label' => $this->l('From'),
                    'name' => 'date_from',
                    'maxlength' => 10,
                    'required' => true,
                    'hint' => $this->l('Format: 2011-12-31 (inclusive).')
                ),
                array(
                    'type' => 'date',
                    'label' => $this->l('To'),
                    'name' => 'date_to',
                    'maxlength' => 10,
                    'required' => true,
                    'hint' => $this->l('Format: 2012-12-31 (inclusive).')
                )
            ),
            'submit' => array(
                'title' => $this->l('Generate PDF file by date'),
                'id' => 'submitPrint',
                'icon' => 'process-icon-download-alt'
            )
        );

        $this->fields_value = array(
            'date_from' => date('Y-m-d'),
            'date_to' => date('Y-m-d')
        );

        $this->table = 'invoice_date';
        $this->show_toolbar = false;
        $this->show_form_cancel_button = false;
        $this->toolbar_title = $this->l('Print PDF invoices');
        return parent::renderForm();
    }

    public function initContent()
    {
        $this->display = 'edit';
        $this->initTabModuleList();
        $this->initToolbar();
        $this->initPageHeaderToolbar();
        $this->content .= $this->initFormByDate();
        $this->table = 'invoice';
        $this->content .= $this->renderOptions();

        $this->context->smarty->assign(array(
            'content' => $this->content,
            'url_post' => self::$currentIndex.'&token='.$this->token,
            'show_page_header_toolbar' => $this->show_page_header_toolbar,
            'page_header_toolbar_title' => $this->page_header_toolbar_title,
            'page_header_toolbar_btn' => $this->page_header_toolbar_btn
        ));
    }

    public function initToolbarTitle()
    {
        $this->toolbar_title = array_unique($this->breadcrumbs);
    }

    public function initPageHeaderToolbar()
    {
        parent::initPageHeaderToolbar();
        unset($this->page_header_toolbar_btn['cancel']);
    }

    public function postProcess()
    {
        if (Tools::isSubmit('submitAddinvoice_date')) {
            if (!Validate::isDate(Tools::getValue('date_from'))) {
                $this->errors[] = $this->l('Invalid "From" date');
            }

            if (!Validate::isDate(Tools::getValue('date_to'))) {
                $this->errors[] = $this->l('Invalid "To" date');
            }

            if (!count($this->errors)) {
                if (count(OrderInvoice::getByDateInterval(Tools::getValue('date_from'), Tools::getValue('date_to')))) {
                    Tools::redirectAdmin($this->context->link->getAdminLink('AdminPdf').'&submitAction=generateInvoicesPDF&date_from='.urlencode(Tools::getValue('date_from')).'&date_to='.urlencode(Tools::getValue('date_to')));
                }

                $this->errors[] = $this->l('No invoice has been found for this period.');
            }
        } elseif (Tools::isSubmit('submitAddinvoice_status')) {
            if (!is_array($status_array = Tools::getValue('id_order_state')) || !count($status_array)) {
                $this->errors[] = $this->l('You must select at least one order status.');
            } else {
                foreach ($status_array as $id_order_state) {
                    if (count(OrderInvoice::getByStatus((int)$id_order_state))) {
                        Tools::redirectAdmin($this->context->link->getAdminLink('AdminPdf').'&submitAction=generateInvoicesPDF2&id_order_state='.implode('-', $status_array));
                    }
                }

                $this->errors[] = $this->l('No invoice has been found for this status.');
            }
        } else {
            parent::postProcess();
        }
    }

    public function beforeUpdateOptions()
    {
        if ((int)Tools::getValue('PS_INVOICE_START_NUMBER') != 0 && (int)Tools::getValue('PS_INVOICE_START_NUMBER') <= Order::getLastInvoiceNumber()) {
            $this->errors[] = $this->l('Invalid invoice number.').Order::getLastInvoiceNumber().')';
        }
    }

    protected function getInvoicesModels()
    {
        $models = array(
            array(
                'value' => 'invoice',
                'name' => 'invoice'
            )
        );

        $templates_override = $this->getInvoicesModelsFromDir(_PS_THEME_DIR_.'pdf/');
        $templates_default = $this->getInvoicesModelsFromDir(_PS_PDF_DIR_);

        foreach (array_merge($templates_default, $templates_override) as $template) {
            $template_name = basename($template, '.tpl');
            $models[] = array('value' => $template_name, 'name' => $template_name);
        }
        return $models;
    }

    protected function getInvoicesModelsFromDir($directory)
    {
        $templates = false;

        if (is_dir($directory)) {
            $templates = glob($directory.'invoice-*.tpl');
        }

        if (!$templates) {
            $templates = array();
        }

        return $templates;
    }
}
