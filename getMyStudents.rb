#http://www.sitepoint.com/web-foundations/mime-types-complete-list/
#https://rameshbaskar.wordpress.com/2013/07/18/setting-firefox-for-silent-file-download/
require 'cgi'
require 'pry'
require 'timeout'
require 'capybara'
require 'capybara/dsl'
require 'launchy'
require 'selenium-webdriver'
load    '/home/haritak/automate/credentials.txt'

class MySchoolMissingLessons
  include Capybara::DSL

  def initialize

    begin
    Dir.mkdir('seleniumDownloads');
    rescue 
      puts "ignoring error while creating dir"
    end
    ap = File.realpath('seleniumDownloads');
    exit unless File.exists?(ap)
    exit unless File.writable?(ap)

    profile = Selenium::WebDriver::Firefox::Profile.new
    profile['browser.download.folderList'] = 2 # 2 - save to user defined location
    profile['browser.download.manager.showWhenStarting']=false
    profile['browser.download.dir']= profile['browser.download.downloadDir']= profile['browser.download.defaultFolder']="#{ap}"
    profile['browser.helperApps.neverAsk.saveToDisk'] = 'application/excel, application/vnd.ms-excel, application/x-excel, application/x-msexcel, application/zip, application/pdf'
    Capybara.register_driver :selenium do |app|
      Capybara::Selenium::Driver.new(
        app, 
        {:browser => :firefox, :profile => profile}
      )
    end
    Capybara.default_driver= :selenium
  end

  def getGrades
    visit 'http://myschool.sch.gr'
    click_link "Σύνδεση"
    fill_in('username', :with=>USERNAME)
    fill_in('password', :with=>PASSWORD)
    click_button('submitForm')
    click_link "ΑΝΑΦΟΡΕΣ"
    click_link "Αναφορές Μαθητών"
    click_link "Βαθμοί"
    click_link "Κατάσταση βαθμολογίας για χειρόγραφη ενημέρωση (με εμφάνιση βαθμών)"
    find('table#ctl00_ContentData_cmbViews').click #show the dropdown menu για την Επιλεγμένη προβολή
    sleep 1
    find('td#ctl00_ContentData_cmbViews_DDD_L_LBI2T0').click #select vgrabber
    sleep 1
    #find('input#ctl00_ContentData_cmbGroupBy_I').click #show dropdown for Ομαδοποίηση
    #sleep 1
    #find('td#ctl00_ContentData_cmbGroupBy_DDD_L_LBI1T0').click #Επιλογή ανα τάξη
    #sleep 1
    find('td#ctl00_ContentData_lstLevel_LBI0T0').click #select A
    click_link("Πρόσθετα κριτήρια")
    sleep 3
    page.driver.browser.switch_to.frame 'ctl00_popupCtrl_CIF1' #Προσθετα κριτήρια
    sleep 2
    find('span#cbpCriteria_lstTOEP_9128_D').click #βαθμοί για το Α τετράμηνο
    find('span#cbpCriteria_lstTOEP_9129_D').click #Β τετράμηνο
    find('span#cbpCriteria_lstTOEP_9132_D').click #Γραπτά
    find('span#cbpCriteria_lstTOEP_9133_D').click #Αναβαθμολόγηση γραπτών
    click_link('Αποδοχή')
    sleep 1

    page.driver.browser.switch_to.default_content
    click_link('Προεπισκόπηση')
    sleep 20
    find('input#ReportToolbar1_Menu_ITCNT13_SaveFormat_I').click
    sleep 1
    find('td#ReportToolbar1_Menu_ITCNT13_SaveFormat_DDD_L_LBI1T0').click
    sleep 3
    find('img#ReportToolbar1_Menu_DXI11_Img').click
    sleep 1
    binding.pry
  end

end

msml = MySchoolMissingLessons.new
msml.getGrades

