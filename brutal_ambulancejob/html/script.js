ChoosedButton = 0
InSubMenu = false
OpenedMDT = false
DeathTimer = false

window.addEventListener('message', function(event) {
    let data = event.data

    if (data.action === "OpenJobMenu"){
      InteractionsTable = data.interactionstable
      CreateJobMenu()
    }
    else if (data.action === "OpenMDTMenu"){
      OpenedMDT = true
      Job = data.job
      Medicers = data.medicers
      Street = data.street
      PlayerName = data.name
      MoneyForm = data.moneyform
      document.getElementById("MDT").style.animation = "Show_panel 0.5s ease";
      $(".MDT").css("display","block")
      $(".logo_img").attr('src', "assets/"+Job.job+".png")
      InsertHomeData()
      RefreshTime()
    }
    else if(data.action === "MDTGetCalls"){
      CitizenCalls = data.table
      PlayerId = data.myid
      CreateCitizenCalls()
    }
    else if(data.action === "MDTGetInvoiceTypes"){
      Invoices = data.table
      TargetName = data.targetname
      CreateInvoices()
      TypeAhead()
    }
    else if(data.action === "OpenMedicerMenu"){
      Damages = data.damagestable
      MedicerItems = data.items
      Mediceryou = data.you
      DeathStatus = data.deathstatus
      Bpm = data.bpm
      Gender = data.gender
      document.getElementById("medic_panel").style.animation = "Show_panel 0.5s ease";
      document.getElementById("medic_panel_me").style.animation = "Show_panel 0.5s ease";
      if (Mediceryou){
        $("#medic_panel_me").css("display","block")
      }
      else{
        $("#medic_panel").css("display","block")
      }
      CreateMedicerMenu()
    }
    else if (data.action === "OpenInteractionMenu"){
      InteractionTable = {"Type" : data.type, "Label" : data.label, "Table" : data.table}
      CreateInteractionMenu()
    }
    else if (data.action === "OpenArmory"){
      CreateArmoryMenu()
    }
    else if (data.action === "OpenShopMenu"){
      ShopItems = data.items
      MoneyForm = data.moneyform
      Card = data.card
      CreateShop(Card)
    }
    else if(data.action === "LiveryMenu"){
      document.getElementById("vehicle_livery").style.animation = "Appear_Menu 0.5s ease";
      $(".vehicle_livery").css("display", "block")
      $("#livery").html("Livery: "+data.livery)
    }
    else if(data.action === "HideLiveryMenu"){
      document.getElementById("vehicle_livery").style.animation = "Hide_panel 0.5s ease";
      setTimeout(function(){
        $(".vehicle_livery").css("display","none")
      }, 400)
    }
    else if(data.action === "CitizenCallMenu"){
      document.getElementById("create_citizen_call").style.animation = "Appear_Menu 0.5s ease";
      $("#create_citizen_call").css("display", "block")
    }
    else if (data.action === "DeathScreen"){
      $(".death_screen").css("display","block")
      let AllTime = data.time
      let Time = data.time
      let DeathCall = data.call
      let Request = data.request
      let WaitTime = data.waittime
      let AllWaitTime = data.waittime
      DeathTimer = true

      function CountbackDeath(){
        if (Time > 0){
          $(`.death_screen .time_con .time`).html(fancyTimeFormat(Time))
          $(`.death_screen .time_con .time_line`).css("width", (Time/AllTime*100)+"%")
        }
        else{
          $(`.death_screen .time_con .time`).html(fancyTimeFormat(WaitTime))
          $(`.death_screen .time_con .time_line`).css("width", (WaitTime/AllWaitTime*100)+"%")
        }
        setTimeout(function(){
          if ((Time > 0 || WaitTime > 0) && DeathTimer){
            if (Time > 0){
              Time = Time - 1 
            }
            else{
              WaitTime = WaitTime - 1 
              if(DeathCall){
                document.getElementById("d_info2").style.animation = "none";
                document.getElementById("hbtn_press2").style.animation = "none";
                $("#d_info2").css("display","block")
              }
              else{
                document.getElementById("d_info").style.animation = "htext_anim 2s ease-in-out";
                document.getElementById("hbtn_press").style.animation = "hbtn_anim 2s ease-in-out";
                setTimeout(function(){
                  $("#d_info").css("display","none")
                  document.getElementById("d_info2").style.animation = "none";
                  document.getElementById("hbtn_press2").style.animation = "none";
                  $("#d_info2").css("display","block")
                }, 2000)
              }
            }
            CountbackDeath()
          }
        },1000)
      }

      if(Request){
        document.getElementById("d_info2").style.animation = "htext_anim 2s ease-in-out";
        document.getElementById("hbtn_press2").style.animation = "hbtn_anim 2s ease-in-out";
        setTimeout(function(){
          $("#d_info2").css("display","none")
        }, 2000)
      }

      if (DeathCall){
        document.getElementById("d_info").style.animation = "htext_anim 2s ease-in-out";
        document.getElementById("hbtn_press").style.animation = "hbtn_anim 2s ease-in-out";
        setTimeout(function(){
          $("#d_info").css("display","none")
        }, 2000)
      }
      else{
        document.getElementById("d_info2").style.animation = "none";
        document.getElementById("d_info").style.animation = "none";
        document.getElementById("hbtn_press").style.animation = "none";
        document.getElementById("hbtn_press2").style.animation = "none";
        $("#d_info").css("display","block")
        $("#d_info2").css("display","none")
        CountbackDeath()
      }
    }
    else if (data.action === "DeathScreenHide"){
      DeathTimer = false
      $(`.death_screen`).css("display", "none")
    }
    else if (data.action === "ControlReleased"){
      Control = data.control
      if(Control === "up" || Control === "down" ){
        ChangeFocus(Control)
      }
      else if(Control === "enter"){
        document.getElementById("circle_"+ChoosedButton).click()
      }
      else if(Control === "backspace"){
        if(InSubMenu){
          BackJobMenu()
        }
        else{
          Close()
        }
      }
    }
    else if (data.action === "close"){
      Close()
    }
})

document.onkeydown = function(data) {
  if (event.key == 'Escape') {
    Close()
  }
}

function Close(){
  CloseMDT()
  CloseShop()
  CloseCitizenCall()
  HideJobMenu()
  CloseMedicPanel()
  HideInteractionMenu()
  setTimeout(function(){
    $('.modal').modal('hide')
  },500)
  $.post('https://'+GetParentResourceName()+'/UseButton', JSON.stringify({action:"close"}))
}

/////////////////////////////////////////////////////////////////////      |  _ \  __ )        \  |  ____|  \  | |   | \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
/////////////////////////////////////////////////////////////////////      | |   | __ \       |\/ |  __|     \ | |   | \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
/////////////////////////////////////////////////////////////////////  \   | |   | |   |      |   |  |     |\  | |   | \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
///////////////////////////////////////////////////////////////////// \___/ \___/ ____/      _|  _| _____|_| \_|\___/  \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
                                           
function ChangeFocus(direction){
  if(direction === "up"){
    if(InSubMenu === false){
      if(InteractionsTable.length >= ChoosedButton +2){
        ChoosedButton++
      }
      else if(InteractionsTable.length === ChoosedButton +1){
        ChoosedButton = 0
      }
    }
    else{
      if(InteractionsTable[SubNumber].table.length > ChoosedButton + 1){
        ChoosedButton++
      }
      else if(InteractionsTable[SubNumber].table.length === ChoosedButton +1){
        ChoosedButton = 0
      }
    }
  }
  else{
    if(InSubMenu === false){
      if(ChoosedButton === 0){
        ChoosedButton = InteractionsTable.length -1
      }
      else{
        ChoosedButton = ChoosedButton -1
      }
    }
    else{
      if(ChoosedButton === 0){
        ChoosedButton = InteractionsTable[SubNumber].table.length -1
      }
      else{
        ChoosedButton = ChoosedButton -1
      }
    }
  }

  if(InSubMenu){
    for(let i=0; i<InteractionsTable[SubNumber].table.length; i++){
      document.getElementById("circle_"+i).classList.remove("hovered_circle")
    }
    Circle_Label = InteractionsTable[SubNumber].table[ChoosedButton].label
  }
  else{
    for(let i=0; i<InteractionsTable.length; i++){
      document.getElementById("circle_"+i).classList.remove("hovered_circle")
    }
    Circle_Label = InteractionsTable[ChoosedButton].label
  }

  document.getElementById("circle_"+ChoosedButton).classList.add("hovered_circle")
  $(".circles_label").html(Circle_Label)
}

function CreateJobMenu(){
  InSubMenu = false
  let Num_elements = InteractionsTable.length
  let Angle = 144/(Num_elements-1)
  let Rot = -108
  ChoosedButton = 0

  document.getElementById("job_menu").style.animation = "ShowJobMenu 1s ease";

  $(".job_menu").css("display","block")

  $(".circle_container").html("")
  for(let i=0; i<Num_elements; i++){
    if (InteractionsTable[i].table == undefined){
      $(".circle_container").append(`
      <button class="circle_element" id="circle_${i}" onclick="SendBackIntButton(id, false)">${InteractionsTable[i].icon}</button>
      `)
    }
    else{
      $(".circle_container").append(`
      <button class="circle_element" id="circle_${i}" onclick="ChangeJobButtons(id)">${InteractionsTable[i].icon}</button>
      `)
    }
    
    $(".job_menu #circle_"+i).css("transform", "rotate("+Rot+"deg) translate(150px) rotate("+Rot*(-1)+"deg)")
    Rot = Rot - Angle
  }
  document.getElementById("circle_"+ChoosedButton).classList.add("hovered_circle")
  $(".circles_label").html(InteractionsTable[0].label)
}

function HideJobMenu(){
  document.getElementById("job_menu").style.animation = "HideJobMenu 1s ease";
  setTimeout(function(){
    $(".job_menu").css("display","none")
  },900)
}

function ChangeJobButtons(id){
  InSubMenu = true
  document.getElementById("job_menu").style.animation = "ChangeJobMenu 0.8s ease";

  SubNumber = id.split('_').pop();
  let Num_elements = InteractionsTable[SubNumber].table.length
  let Angle = 144/(Num_elements-1)
  let Rot = -108

  setTimeout(function(){
    $(".circle_container").html("")
    for(let i=0; i<Num_elements; i++){
      $(".circle_container").append(`
      <button class="circle_element" id="circle_${i}" onclick="SendBackIntButton(id, true)">${InteractionsTable[SubNumber].table[i].icon}</button>
      `)
      $(".job_menu #circle_"+i).css("transform", "rotate("+Rot+"deg) translate(150px) rotate("+Rot*(-1)+"deg)")
      Rot = Rot - Angle
    }
    ChoosedButton = 0
    document.getElementById("circle_"+ChoosedButton).classList.add("hovered_circle")
    $(".circles_label").html(InteractionsTable[SubNumber].table[0].label)
  },400)

  if (SubNumber == 2){
	$.post('https://'+GetParentResourceName()+'/UseButton', JSON.stringify({action:"JobMenuObject"}))
  }
}

function BackJobMenu(){
  InSubMenu = false
  let Num_elements = InteractionsTable.length
  let Angle = 144/(Num_elements-1)
  let Rot = -108

  document.getElementById("job_menu").style.animation = "BackJobMenu 0.8s ease";

  setTimeout(function(){
    $(".circle_container").html("")
    for(let i=0; i<Num_elements; i++){
      if (InteractionsTable[i].table == undefined){
        $(".circle_container").append(`
        <button class="circle_element" id="circle_${i}" onclick="SendBackIntButton(id, false)">${InteractionsTable[i].icon}</button>
        `)
      }
      else{
        $(".circle_container").append(`
        <button class="circle_element" id="circle_${i}" onclick="ChangeJobButtons(id)">${InteractionsTable[i].icon}</button>
        `)
      }
      $(".job_menu #circle_"+i).css("transform", "rotate("+Rot+"deg) translate(150px) rotate("+Rot*(-1)+"deg)")
      Rot = Rot - Angle
    }
    ChoosedButton = 0
    document.getElementById("circle_"+ChoosedButton).classList.add("hovered_circle")
    $(".circles_label").html(InteractionsTable[0].label)
  },400)
}

function SendBackIntButton(id, value){
  let idnumber = id.split('_').pop()
  
  if (value == true){
    for(let i=0; i<InteractionsTable[SubNumber].table.length; i++){
      if (i == idnumber){
        $.post('https://'+GetParentResourceName()+'/UseButton', JSON.stringify({action:"JobMenu", id:InteractionsTable[SubNumber].table[i].id}))
        break
      }
    }
  }
  else{
    for(let i=0; i<InteractionsTable.length; i++){
      if (i == idnumber){
        HideJobMenu()
        $.post('https://'+GetParentResourceName()+'/UseButton', JSON.stringify({action:"JobMenu", id:InteractionsTable[i].id}))
        break
      }
    }
  }
}


//////////////////////////////////////////////////////////////// INTERACTIONS \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

function CreateInteractionMenu(){
  $(".interactions h2").html(InteractionTable.Label)

  $(".int_con_sec").html("")
  for(let i=0; i<InteractionTable.Table.length; i++){
    $(".int_con_sec").append(`
    <div class="col">
        <div class="d-flex flex-column justify-content-center align-items-center">
            <button class="long_btn mb-3" id="${InteractionTable.Table[i].id}" onclick="SetDress(id)">${InteractionTable.Table[i].label}</button>
        </div>
    </div>
    `)
    if (InteractionTable.Table[i].label.length > 17){
      $("#"+InteractionTable.Table[i].id).css("font-size", "15px")
    }
  }
  document.getElementById("interactions").style.animation = "ShowIneractionMenu 0.7s ease";
  $(".interactions").css("display","block")
}

function SetDress(id){
  Close()
  $.post('https://'+GetParentResourceName()+'/UseButton', JSON.stringify({action:"interactionmenu", id, table:InteractionTable}))
}

function CreateArmoryMenu(){
  $(".interactions h2").html("Storage")

  $(".int_con_sec").html("")
  $(".int_con_sec").html(`
		<div class="col">
			<div class="d-flex flex-column justify-content-center align-items-center">
			<button class="long_btn mb-3" onclick="Armory()">Armory</button>
			</div>
		</div>
		<div class="col">
			<div class="d-flex flex-column justify-content-center align-items-center">
			<button class="long_btn mb-3" onclick="Buy()">Shop</button>
			</div>
		</div>
	`)

  document.getElementById("interactions").style.animation = "ShowIneractionMenu 0.7s ease";
  $(".interactions").css("display","block")
}

function Armory(){
  Close()
  $.post('https://'+GetParentResourceName()+'/UseButton', JSON.stringify({action:"armory"}))
}

function Buy(){
  HideInteractionMenu()
  $.post('https://'+GetParentResourceName()+'/UseButton', JSON.stringify({action:"armory-shop"}))
}

function HideInteractionMenu(){
  document.getElementById("interactions").style.animation = "HideInteractionMenu 0.7s ease";
  setTimeout(function(){
    $(".interactions").css("display","none")
  },680)
}

///////////////////////////////////////////////////////////////// SHOP MENU \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

function CreateShop(value){
  $(".shop").css("display", "block")
  setTimeout(function(){
    $(".shop").css("scale", "1")
  }, 50)

  if (value == true){
    $(".slider_btn").css("display", "block")
    $("#shop_back").css("display", "block")
  }
  else{
    $(".slider_btn").css("display", "none")
    $("#shop_back").css("display", "none")
  }

  $(".shop_elements_container").html("")
  for(let i=0; i<ShopItems.length; i++){
    $(".shop_elements_container").append(`
    <div class="col">
        <div class="d-flex flex-column justify-content-center align-items-center">
            <div class="shop_element">
                <img class="mx-auto d-block" src="assets/${ShopItems[i].item}.png"></img>
                <h4>${ShopItems[i].label}</h4>
                <div class="mx-auto d-block">
                    <div class="input-group input-group-lg num">
                        <input class="form-control" id="${ShopItems[i].item}" type="text" autofocus="autofocus" value="0" oninput="setlenght(id)" onkeypress="return isNumber(event)">
                    </div>
                </div>
            </div>
        </div>
    </div>
    `)
  }
}

function BuyInShop(){
  BuyItems = []
  for (let i = 0; i < ShopItems.length; i++) {
    if (document.getElementById(ShopItems[i].item).value > 0){
      BuyItems.push([ShopItems[i].item, document.getElementById(ShopItems[i].item).value, ShopItems[i].price, ShopItems[i].label])
    }
  }

  if (BuyItems.length > 0){
    let Element = document.getElementById("slider_shop")
    let Left = Element.offsetLeft
    if (Left == 0){
      $.post('https://'+GetParentResourceName()+'/UseButton', JSON.stringify({action:"BuyInShop", BuyItems, paytype:"money"}))
    }
    else{
      $.post('https://'+GetParentResourceName()+'/UseButton', JSON.stringify({action:"BuyInShop", BuyItems, paytype:"bank"}))
    }
  }

  setTimeout(function(){
    for (let i = 0; i < ShopItems.length; i++) {
      document.getElementById(ShopItems[i].item).value = 0
    }
    changemoney()
  }, 200)
}

function changemoney(){
  let AllMoney = 0
  for (let i = 0; i < ShopItems.length; i++) {
    AllMoney += ShopItems[i].price * document.getElementById(ShopItems[i].item).value
  }
  $('.checkout_container h3').html('TOTAL: '+AllMoney+'<money>'+MoneyForm+'</money>')
}

function ChangeSliderbtn(id){
  if (id == "shop_slider"){
    let Element = document.getElementById("slider_shop")
    let Left = Element.offsetLeft
    if (Left == 0){
      Element.style.left = "50%"
    }
    else{
      Element.style.left = "0%"
    }
  }
  else if (id == "MDT_slider"){
    let Element = document.getElementById("slider_MDT")
    let Left = Element.offsetLeft
    if (Left == 0){
      Element.style.left = "50%"
      ChangeSearch("vehicles")
    }
    else{
      Element.style.left = "0%"
      ChangeSearch("people")
    }
  }
}

function CloseShop(){
  $(".shop").css("scale", "0")
  setTimeout(function(){
    $(".shop").css("display", "none")
  }, 600)
}

/////////////////////////////////////////////////////////////////////   \  |  __ \ __ __| \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
/////////////////////////////////////////////////////////////////////  |\/ |  |   |   |   \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
/////////////////////////////////////////////////////////////////////  |   |  |   |   |   \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
///////////////////////////////////////////////////////////////////// _|  _| ____/   _|   \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\         

function CloseMDT(){
  document.getElementById("MDT").style.animation = "Hide_panel 0.5s ease";
  setTimeout(function(){
    $(".MDT").css("display","none")
    if (OpenedMDT){
      SwitchPage("home")
    }
    OpenedMDT = false
  }, 400)
}

function SwitchPage(id){

  if (id == "home"){
    MoveBackLogo()
    $(".page_data_container").html(`
    <div class="background_blur_color"></div>
    <div class="home_label mt-3">
    <div class="background_effect"></div>
        <div class="row">
            <div class="col ms-3 mt-1" id="job_name"></div>
            <div class="col-2 mt-1" id="home_date">date 213 23</div>
            <div class="col me-3 mt-1 text-end" id="street"></div>
        </div>
    </div>

    <div class="row mt-3 mx-2">
        <div class="col">
            <div class="home_stat_con mx-auto d-block">
            <div class="background_effect"></div>
                <div class="label">Medicers</div>
                <div class="main" id="available_medicers">0</div>
            </div>
        </div>
        <div class="col">
            <div class="home_stat_con mx-auto d-block">
            <div class="background_effect"></div>
                <div class="label">Rank</div>
                <div class="main small" id="player_rang"></div>
            </div>
        </div>
        <div class="col">
            <div class="home_stat_con mx-auto d-block">
            <div class="background_effect"></div>
                <div class="label">Salary</div>
                <div class="main" id="salary">100$</div>
            </div>
        </div>
    </div>

    <div class="welcome_text mt-3">Welcome,<br> <span class="hand_written">Name</span></div>
      
    `)
    InsertHomeData()
  }
  else if (id == "invoices"){
    MoveLogo()
    $.post('https://'+GetParentResourceName()+'/UseButton', JSON.stringify({action:"MDTInvoices", type:"get"}))
    $(".page_data_container").html(`
    <div class="row mt-3">
      <div class="col-5">
          <h2 class="sub_label">Create an invoice</h2>
          <div class="input-group input-group-lg mt-3 px-3">
              <input type="text" id="invoice_name" class="form-control text-center" placeholder="Name..." oninput="RefreshCreateInvoiceBTN()" >
          </div>
          <div class="input-group input-group-lg mt-3 px-3">
              <input type="text" id="invoice_value" class="form-control text-center" placeholder="Value..." oninput="RefreshCreateInvoiceBTN()" onkeypress="return isNumber(event)">
          </div>
          <button class="submenu_btn px-3 m-3 mb-5 mx-auto d-block" id="create_invoice_btn" disabled onclick="CreateInvoice()">Create</button>
          <h2 class="sub_label mt-5">Give an invoice</h2>
          <div class="input-group input-group-lg mt-3 px-3">
            <input type="text" id="in_give_invoice" class="form-control text-center rounded typeahead" data-provide="typeahead" placeholder="Label..." onchange="RefreshGiveInvoiceBTN()" oninput="RefreshGiveInvoiceBTN()">
          </div>
          <hr style="width: 80%; margin-left: 10%; border-top: solid 3px white; border-radius: 3px;">
          <div class="give_invoiceto_con">
            <div class="background_effect"></div>
            <h2 class="sub_label" id="target_player">-</h2>
            <h2 class="sub_label" id="invoice_price">0$</h2>
          </div>
          <button class="submenu_btn px-3 m-3 mx-auto d-block" id="give_invoice_btn" disabled onclick="GiveInvoice()">Give</button>
        </div>
      <div class="col">
          <h2 class="sub_label">Invoices</h2>
          <div class="invoices_container mt-3">
          <div class="background_blur_color"></div>

          </div>
      </div>
    </div>
    `)
  }
  else if (id == "sos_alert"){
    MoveLogo()
    $.post('https://'+GetParentResourceName()+'/UseButton', JSON.stringify({action:"MDTCitizenCall", type:"getcalls"}))
    $(".page_data_container").html(`InsertHomeData
      <div class="cam_shadow">
      </div>
      <div class="alert_container_out mt-3">
        <div class="alert_container row row-cols-2 p-4">
        
        </div>
      </div>
    `)
  }
}

function InsertHomeData(){
  $("#available_medicers").html(Medicers)
  $("#player_rang").html(Job.label)
  $("#salary").html(Job.salary+MoneyForm)
  $("#job_name").html(Job.name+" - Database")
  $("#street").html(`<i class="fa-solid fa-location-dot"></i> `+Street[0]+",<br>"+Street[1])
  $(".welcome_text .hand_written").html(PlayerName)

  if (Job.label.length > 6){
    $(".home_stat_con .small").css("font-size", "30px")
  }
}

function RefreshTime(){
  if (OpenedMDT){
    setTimeout(function(){
      RefreshTime()
    },100)
  }
  
  var date=new Date();  
  var day=date.getDate();  
  var month=date.getMonth()+1;  
  var year=date.getFullYear();  
  $("#home_date").html(day+"/"+month+"/"+year+"<br>"+date.toLocaleTimeString()); 
}

function MoveLogo(){
  $(".logo_img").css({
    "height": "80px",
    "left": "15.2px",
  })
}

function MoveBackLogo(){
  $(".logo_img").css({
    "height": "200px",
    "left": "870px",
  })
}

function CreateCitizenCalls(){
  $(".alert_container_out").html(`
  <div class="alert_container row row-cols-2 p-4"></div>
  `)
  let IsRealCall = false
  if (CitizenCalls.length > 0){
    for (let i = 0; i < CitizenCalls.length; i++) {
      if (CitizenCalls[i].closed == false){
        IsRealCall = true
        if (CitizenCalls[i].medicers.length > 0){
          $(".alert_container").append(`
              <div class="col">
                <div class="alert_element mx-auto d-block" id="alert_element_${i}">
                <div class="background_effect"></div>
                    <div class="row">
                        <div class="col"><h2>Citizen call</h2></div>
                        <div class="col"><div class="police_on"><i class="fa-solid fa-user-group"></i> ${CitizenCalls[i].medicers.length}</div></div>
                    </div>
                    <div class="main_text">${CitizenCalls[i].text}</div>
                    <div class="row">
                        <div class="col-3">
                            <button class="details_btn px-3 m-3 mt-2" id="call_${i}" onclick="RefreshCallModul(id)" data-bs-toggle="modal" data-bs-target="#call_modal">More</button>
                        </div>
                        <div class="col">
                            <div class="street">${CitizenCalls[i].street}</div>
                        </div>
                    </div>
                </div>
            </div>
          `)
        }
        else{
          $(".alert_container").append(`
              <div class="col">
                <div class="alert_element mx-auto d-block" id="alert_element_${i}">
                <div class="background_effect"></div>
                    <div class="row">
                        <div class="col"><h2>Citizen call</h2></div>
                        <div class="col"><div class="police_on"><i class="fa-solid fa-user-group"></i> ${CitizenCalls[i].medicers.length}</div></div>
                    </div>
                    <div class="main_text">${CitizenCalls[i].text}</div>
                    <div class="row">
                        <div class="col-3">
                            <button class="details_btn px-3 m-3 mt-2" id="call_${i}" onclick="RefreshCallModul(id), AcceptCall()" data-bs-toggle="modal" data-bs-target="#call_modal">Accept</button>
                        </div>
                        <div class="col">
                            <div class="street">${CitizenCalls[i].street}</div>
                        </div>
                    </div>
                </div>
            </div>
          `)
        }
      }
      
      if (CitizenCalls[i].medicers.length > 0){
        $("#alert_element_"+i).css("background-image", "linear-gradient(var(--main_color_darker), var(--main_color))")
        $("#alert_element_"+i+" .main_text").css("background-image", "linear-gradient(rgba(119, 45, 35, 0.548), rgba(175, 67, 53, 0.548))")
      }
    }
  }
  else{
    $(".alert_container_out").html(`
    <div class="col not_found_con py-1"><h1 class="text-center">There isn't any call</h1></div>
    `)
  }

  if (IsRealCall == false){
    $(".alert_container_out").html(`
    <div class="col not_found_con py-1"><h1 class="text-center">There isn't any call</h1></div>
    `)
  }
}

function CreateInvoices(){
  document.getElementById("target_player").innerHTML = TargetName
  $(".invoices_container").html(`<div class="background_blur_color"></div>`)
  for (let i = 0; i < Invoices.length; i++) {
    $(".invoices_container").append(`
      <div class="invoice_element" id="${i}" onclick="ShowDeleteBTN(id)">
          <div class="background_effect"></div>
          <div class="row invoice_row" id="invoice_row_${i}">
              <div class="col">
                  <h2 class="name mt-2">${Invoices[i].label}</h2>
              </div>
              <div class="col">
                  <h2 class="value mt-2">${Invoices[i].amount+MoneyForm}</h2>
              </div>
              <div class="delete_con" id="del_${i}" onclick="DeleteInvoice(id)">
                  <div class="txt">Delete <i class="fa-solid fa-trash"></i></div>
              </div>
          </div>
      </div>
    `)
  }
}

function RefreshCallModul(id){
  CallNumber = id.split('_')[1]
  let Accepted = false

  $(".involved_container").html("")
  for (let i = 0; i < CitizenCalls[CallNumber].medicers.length; i++) {
    if (CitizenCalls[CallNumber].medicers[i].id == PlayerId){
      Accepted = true
    }
    $(".involved_container").append(`
    <div class="involved_element">
        ${CitizenCalls[CallNumber].medicers[i].name}
    </div>
    `)
    if (i +1 < CitizenCalls[CallNumber].medicers.length){
      $(".involved_container").append(`
      <hr>
      `)
    }
  }

  if (CitizenCalls[CallNumber].closed == false){
    if (Accepted == true){
      $(".call_actions_container").html(`
      <div class="input-group mt-3 call_reason_con">
          <textarea class="form-control mx-4" id="in_call_reason" oninput="RefreshCloseCallBTN()" placeholder="Reason to close"></textarea>
      </div>
    	<button class="submenu_btn px-3 my-3 mx-auto d-block" id="close_call" data-bs-dismiss="modal" onclick="CloseCall()" disabled>Close</button>
      `)
    }
  }
  else{
    $(".call_actions_container").html(`
		<h3 class="text-white text-center mt-3">Reason to close</h3>
		<div class="input-group call_reason_con">
			<textarea class="form-control mx-4" id="in_call_reason" disabled>${CitizenCalls[CallNumber].reason}</textarea>
		</div>
    `)
  }
}

function AcceptCall(){
  $(".call_actions_container").html(`
  <div class="input-group mt-3 call_reason_con">
      <textarea class="form-control mx-4" id="in_call_reason" oninput="RefreshCloseCallBTN()" placeholder="Reason to close..."></textarea>
  </div>
	<button class="submenu_btn my-3 px-3 mx-auto d-block" id="close_call" data-bs-dismiss="modal" onclick="CloseCall()" disabled>Close</button>
  `)

  let tableid = +CallNumber + +1
  $.post('https://'+GetParentResourceName()+'/UseButton', JSON.stringify({action:"MDTCitizenCall", type:"accept", tableid}))

  setTimeout(function(){
    $(".involved_container").html("")
    for (let i = 0; i < CitizenCalls[CallNumber].medicers.length; i++) {
      $(".involved_container").append(`
      <div class="involved_element">
          ${CitizenCalls[CallNumber].medicers[i].name}
      </div>
      `)
      if (i +1 < CitizenCalls[CallNumber].medicers.length){
        $(".involved_container").append(`
        <hr>
        `)
      }
    }
  },700)
}

function CloseCall(){
  let tableid = +CallNumber + +1
  let text = document.getElementById("in_call_reason").value
  $.post('https://'+GetParentResourceName()+'/UseButton', JSON.stringify({action:"MDTCitizenCall", type:"close", tableid, text}))
  
  document.getElementById("in_call_reason").value = ""
}

function SendPinOnMap(){
  Close()
  let tableid = +CallNumber + +1
  let coords = CitizenCalls[CallNumber].coords
  $.post('https://'+GetParentResourceName()+'/UseButton', JSON.stringify({action:"MDTCitizenCall", type:"blip", coords, tableid}))
}

function RefreshCloseCallBTN(){
  let reason = document.getElementById("in_call_reason").value

  if (reason.length > 0){
    document.getElementById("close_call").disabled = false
  }
  else{
    document.getElementById("close_call").disabled = true
  }
}

function ShowDeleteBTN(id){
  if (window.getComputedStyle(document.getElementById("invoice_row_"+id)).width == "680px"){
    $("#invoice_row_"+id).css("width", "550px")
    $("#invoice_row_"+id+" .name").css("font-size", "25px")
  }
  else{
    $("#invoice_row_"+id).css("width", "680px")
    $("#invoice_row_"+id+" .name").css("font-size", "32px")
  }
}

function RefreshCreateInvoiceBTN(){
  let name = document.getElementById("invoice_name").value
  let value = document.getElementById("invoice_value").value

  if (name.length > 0 && value.length > 0){
    document.getElementById("create_invoice_btn").disabled = false
  }
  else{
    document.getElementById("create_invoice_btn").disabled = true
  }
}

function CreateInvoice(){
  let label = document.getElementById("invoice_name").value
  let amount = document.getElementById("invoice_value").value
  $.post('https://'+GetParentResourceName()+'/UseButton', JSON.stringify({action:"MDTInvoices", type:"create", label, amount}))
  document.getElementById("invoice_name").value = ""
  document.getElementById("invoice_value").value = ""
  setTimeout(function(){
    SwitchPage("invoices")
  }, 200)
}

function DeleteInvoice(id){
  number = Invoices[(id.split('_')[1])].id
  $.post('https://'+GetParentResourceName()+'/UseButton', JSON.stringify({action:"MDTInvoices", type:"delete", number}))
  setTimeout(function(){
    SwitchPage("invoices")
  }, 200)
}

function RefreshGiveInvoiceBTN(){
  let name = document.getElementById("in_give_invoice").value 
  let found = false
  for(let i = 0; i < Invoices.length; i++){
    if (name === Invoices[i].label){
      document.getElementById("invoice_price").innerHTML = Invoices[i].amount + MoneyForm
      found = true
    }
  }

  if (found){
    if (TargetName != "-"){
      document.getElementById("give_invoice_btn").disabled = false
    }
  }
  else{
    document.getElementById("give_invoice_btn").disabled = true
    document.getElementById("invoice_price").innerHTML = "0"+MoneyForm
  }
}

function GiveInvoice(){
  let label = document.getElementById("in_give_invoice").value
  let amount
  for(let i = 0; i < Invoices.length; i++){
    if (label === Invoices[i].label){
      amount = Invoices[i].amount
    }
  }
  $.post('https://'+GetParentResourceName()+'/UseButton', JSON.stringify({action:"MDTInvoices", type:"give", label, amount}))
  document.getElementById("in_give_invoice").value = ""
  document.getElementById("invoice_price").innerHTML = "0"+MoneyForm
}

function TypeAhead(){
  TypeAheadList = []
    for(let i = 0; i < Invoices.length; i++){
      TypeAheadList.push(Invoices[i].label)
    }
  
    var $input = $(".typeahead");
    $input.typeahead({
      autocomplete: true,
      source: TypeAheadList,
    });CreateMedicerMenu
  
    $input.change(function() {
        var current = $input.typeahead("getActive");
        matches = [];
  
        if (current) {
          if (current.name == $input.val()) {
              matches.push(current.name);
          }
        }
    });
}

function RefreshCreateCallBTN(){
  let in_citizen_call_reason = document.getElementById("in_citizen_call_reason").value

  if (in_citizen_call_reason.length > 0){
      document.getElementById("create_call_btn").disabled = false
  }
  else{
      document.getElementById("create_call_btn").disabled = true
  }
}

function CreateCall(){
  let text = document.getElementById("in_citizen_call_reason").value
  $.post('https://'+GetParentResourceName()+'/UseButton', JSON.stringify({action:"MDTCitizenCall", type:"create", text}))
  Close()
  document.getElementById("in_citizen_call_reason").value = ""
}

function CloseCitizenCall(){
  document.getElementById("create_citizen_call").style.animation = "Hide_panel 0.5s ease";
  setTimeout(function(){
    $("#create_citizen_call").css("display","none")
  }, 400)
}

///////////////////////////////////////////////////////////// MEDIC PANEL \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

function CreateMedicerMenu(){

  if (Gender == 0){
    $(".main_body").attr('src', "assets/main_body_w.png")
    $("#head").attr('src', "assets/head_w.png")
    $("#body").attr('src', "assets/body_w.png")
    $("#right_arm").attr('src', "assets/right_arm_w.png")
    $("#left_arm").attr('src', "assets/left_arm_w.png")
    $("#right_leg").attr('src', "assets/right_leg_w.png")
    $("#left_leg").attr('src', "assets/left_leg_w.png")
  }
  else{
    $(".main_body").attr('src', "assets/main_body.png")
    $("#head").attr('src', "assets/head.png")
    $("#body").attr('src', "assets/body.png")
    $("#right_arm").attr('src', "assets/right_arm.png")
    $("#left_arm").attr('src', "assets/left_arm.png")
    $("#right_leg").attr('src', "assets/right_leg.png")
    $("#left_leg").attr('src', "assets/left_leg.png")
  }

  DisplayOrNot(Damages.head, "head")
  DisplayOrNot(Damages.body, "body")
  DisplayOrNot(Damages.larm, "left_arm")
  DisplayOrNot(Damages.rarm, "right_arm")
  DisplayOrNot(Damages.lleg, "left_leg")
  DisplayOrNot(Damages.rleg, "right_leg")

  if (DeathStatus){
    $(".status_con .box").css("color", "rgb(223, 62, 62)")
    $(".status_con .box").html("COMATOSE")
  }
  else{
    if (Damages.bleeding){
      $(".status_con .box").css("color", "rgb(223, 62, 62)")
      $(".status_con .box").html("BLEEDING")
    }
    else{
      $(".status_con .box").css("color", "rgba(127, 255, 212, 0.87)")
      $(".status_con .box").html("NORMAL")
    }
  }
  

  if (Mediceryou){
    $(".patient").html("YOU")

    dragMedicElement(document.getElementById("blood_me"), "blood")
    DisplayMedicerItem(MedicerItems.Bandage, "blood_me")
  }
  else{
    $(".patient").html("PLAYER")

    dragMedicElement(document.getElementById("head_heal"),"head_heal")
    dragMedicElement(document.getElementById("body_heal"), "body_heal")
    dragMedicElement(document.getElementById("arm_heal"), "arm_heal")
    dragMedicElement(document.getElementById("leg_heal"), "leg_heal")
    dragMedicElement(document.getElementById("blood"), "blood")
    dragMedicElement(document.getElementById("revive"), "revive")

    DisplayMedicerItem(MedicerItems.Head, "head_heal")
    DisplayMedicerItem(MedicerItems.Body, "body_heal")
    DisplayMedicerItem(MedicerItems.Arms, "arm_heal")
    DisplayMedicerItem(MedicerItems.Legs, "leg_heal")
    DisplayMedicerItem(MedicerItems.Bandage, "blood")
    DisplayMedicerItem(MedicerItems.Medikit, "revive")
  }

  $(".bpm_con .box").html(Bpm)
}

function DisplayMedicerItem(value, id){
  if (value != false){
    $("#"+id).css("display", "block")
    document.getElementById(id).src = "assets/"+value+".png"
  }
  else{
    $("#"+id).css("display", "none")
  }
}

function DisplayOrNot(value, id){
  if (value){
    $("#"+id).css("display", "block")
    $("#"+id+"2").css("display", "block")
  }
  else{
    $("#"+id).css("display", "none")
    $("#"+id+"2").css("display", "none")
  }
}

function CloseMedicPanel(){
  document.getElementById("medic_panel").style.animation = "Hide_panel 0.5s ease";
  document.getElementById("medic_panel_me").style.animation = "Hide_panel 0.5s ease";
  setTimeout(function(){
    $(".medic_panel").css("display","none")
  }, 400)
}

OGPos = {"head_heal": {x: null, y:null}, "body_heal":  {x: null, y:null}, "arm_heal":  {x: null, y:null}, "leg_heal":  {x: null, y:null},"blood":  {x: 12, y: 12},"revive":  {x: null, y:null}}

function dragMedicElement(elmnt, item) {
  var pos1 = 0, pos2 = 0, pos3 = 0, pos4 = 0;

  if (OGPos[item].x == null){
    OGPos[item].x = elmnt.offsetLeft
    OGPos[item].y = elmnt.offsetTop
  }

  elmnt.onmousedown = dragMouseDown

  function dragMouseDown(e) {
    e = e || window.event;
    e.preventDefault();

    pos3 = e.clientX;
    pos4 = e.clientY;
    document.onmouseup = closeDragElement;
    document.onmousemove = elementDrag;
  }

  function elementDrag(e) {
    e = e || window.event
    e.preventDefault()

    pos1 = pos3 - e.clientX
    pos2 = pos4 - e.clientY
    pos3 = e.clientX
    pos4 = e.clientY

    elmnt.style.opacity = "0.8"

    elmnt.style.top = (elmnt.offsetTop - pos2) + "px"
    elmnt.style.left = (elmnt.offsetLeft - pos1) + "px"

    if (Mediceryou){
      if (elementsOverlap(elmnt, document.getElementById("medic_panel_me")) == false){
        closeDragElement()
      }
    }
    else{
      if (elementsOverlap(elmnt, document.getElementById("medic_panel")) == false){
        closeDragElement()
      }
    }
    
  }

  function closeDragElement() {
    UseMedicItem(elmnt, item)
    elmnt.style.opacity = "1"
    document.onmouseup = null;
    document.onmousemove = null;
  }
}

function UseMedicItem(elmnt, item){
  let elm = elmnt
  if (Damages.bleeding == false && DeathStatus == false){
    if (item == "head_heal"){
      if (elementsOverlap(elm, document.getElementById("head_box")) && Damages.head){
        ItemAnim(elm, item)
      }
      else if(elementsOverlap(elm, document.getElementById("head_box")) && Damages.head == false){
        WrongItemAnim(elm, item)
      }
      else{
        elm.style.top = OGPos[item].y + "px"
        elm.style.left = OGPos[item].x + "px"
      }
    }
    else if (item == "body_heal"){
      if (elementsOverlap(elm, document.getElementById("body_box")) && Damages.body){
        ItemAnim(elm, item)
      }
      else if(elementsOverlap(elm, document.getElementById("body_box")) && Damages.body == false){
        WrongItemAnim(elm, item)
      }
      else{
        elm.style.top = OGPos[item].y + "px"
        elm.style.left = OGPos[item].x + "px"
      }
    }
    else if (item == "arm_heal"){
      if (elementsOverlap(elm, document.getElementById("right_arm_box")) && Damages.rarm){
        ItemAnim(elm, item, "right")
      }
      else if(elementsOverlap(elm, document.getElementById("right_arm_box")) && Damages.rarm == false){
        WrongItemAnim(elm, item)
      }
      else if (elementsOverlap(elm, document.getElementById("left_arm_box")) && Damages.larm){
        ItemAnim(elm, item, "left")
      }
      else if(elementsOverlap(elm, document.getElementById("left_arm_box")) && Damages.larm == false){
        WrongItemAnim(elm, item)
      }
      else{
        elm.style.top = OGPos[item].y + "px"
        elm.style.left = OGPos[item].x + "px"
      }
    }
    else if (item == "leg_heal"){
      if (elementsOverlap(elm, document.getElementById("right_leg_box")) && Damages.rleg){
        ItemAnim(elm, item, "right")
      }
      else if(elementsOverlap(elm, document.getElementById("right_leg_box")) && Damages.rleg == false){
        WrongItemAnim(elm, item)
      }
      else if (elementsOverlap(elm, document.getElementById("left_leg_box")) && Damages.lleg){
        ItemAnim(elm, item, "left")
      }
      else if(elementsOverlap(elm, document.getElementById("left_leg_box")) && Damages.lleg == false){
        WrongItemAnim(elm, item)
      }
      else{
        elm.style.top = OGPos[item].y + "px"
        elm.style.left = OGPos[item].x + "px"
      }
    }
    else if (item == "blood"){
      if (elementsOverlap(elm, document.getElementById("body_box")) || elementsOverlap(elm, document.getElementById("body_box2")) || elementsOverlap(elm, document.getElementById("right_leg_box")) || elementsOverlap(elm, document.getElementById("left_leg_box")) || elementsOverlap(elm, document.getElementById("right_arm_box")) || elementsOverlap(elm, document.getElementById("left_arm_box")) || elementsOverlap(elm, document.getElementById("head_box"))){
        WrongItemAnim(elm, item)
      }
      else{
        elm.style.top = OGPos[item].y + "px"
        elm.style.left = OGPos[item].x + "px"
      }
    }
    else if (item == "revive"){
      if (elementsOverlap(elm, document.getElementById("body_box"))){
        WrongItemAnim(elm, item)
      }
      else{
        elm.style.top = OGPos[item].y + "px"
        elm.style.left = OGPos[item].x + "px"
      }
    }
  }
  else if(DeathStatus){
    if (item == "revive"){
      if (elementsOverlap(elm, document.getElementById("body_box"))){
        ItemAnim(elm, item)
      }
      else{
        elm.style.top = OGPos[item].y + "px"
        elm.style.left = OGPos[item].x + "px"
      }
    }
    else{
        elm.style.top = OGPos[item].y + "px"
        elm.style.left = OGPos[item].x + "px"
    }
  }
  else{
    if (item == "blood"){
      if (elementsOverlap(elm, document.getElementById("body_box")) || elementsOverlap(elm, document.getElementById("body_box2")) || elementsOverlap(elm, document.getElementById("right_leg_box")) || elementsOverlap(elm, document.getElementById("left_leg_box")) || elementsOverlap(elm, document.getElementById("right_arm_box")) || elementsOverlap(elm, document.getElementById("left_arm_box")) || elementsOverlap(elm, document.getElementById("head_box")) && Damages.bleeding){
        ItemAnim(elm, item)
      }
      else if (elementsOverlap(elm, document.getElementById("body_box")) || elementsOverlap(elm, document.getElementById("body_box2")) || elementsOverlap(elm, document.getElementById("right_leg_box")) || elementsOverlap(elm, document.getElementById("left_leg_box")) || elementsOverlap(elm, document.getElementById("right_arm_box")) || elementsOverlap(elm, document.getElementById("left_arm_box")) || elementsOverlap(elm, document.getElementById("head_box")) && Damages.bleeding == false){
        WrongItemAnim(elm, item)
      }
      else{
        elm.style.top = OGPos[item].y + "px"
        elm.style.left = OGPos[item].x + "px"
      }
    }
    else{
      WrongItemAnim(elm, item)
    }
  }
}

function ItemAnim(elm, item, part){
  elm.style.animation = 'none';
  elm.offsetHeight;
  elm.style.animation = "itemuseanim 1.2s";
  setTimeout(function(){
    elm.style.top = OGPos[item].y + "px"
    elm.style.left = OGPos[item].x + "px"
    elm.style.animation = 'none';
    Close()
  },1200)

  $.post('https://'+GetParentResourceName()+'/UseButton', JSON.stringify({action:"MedicerMenu", type:"useitem", item, you:Mediceryou, part}))
}

function WrongItemAnim(elm, item){
  elm.style.animation = 'none';
  elm.offsetHeight;
  elm.style.animation = "itemnotuseanim 0.8s";
  setTimeout(function(){
    elm.style.top = OGPos[item].y + "px"
    elm.style.left = OGPos[item].x + "px"
    elm.style.animation = 'none';
  },800)
}

/////////////////////////////////////////////////////////////// BASIC FUNCTIONS \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\


function isNumber(evt) {
  evt = (evt) ? evt : window.event
  var charCode = (evt.which) ? evt.which : evt.keyCode
  if (charCode > 31 && (charCode < 48 || charCode > 57)) {
      return false
  }
  return true
}

function setlenght(id) {
  if (document.getElementById(id).value.length === 2 && document.getElementById(id).value[0] == 0){
    document.getElementById(id).value = document.getElementById(id).value.substring(1)
  }
  if (document.getElementById(id).value.length === 4){
    document.getElementById(id).value = document.getElementById(id).value.substring(1)
  }
  if (document.getElementById(id).value.length === 0){
    document.getElementById(id).value = 0
  }
  changemoney()
  return true
}

function dragElement(elmnt) {
  var pos1 = 0, pos2 = 0, pos3 = 0, pos4 = 0;

  elmnt.onmousedown = dragMouseDown;

  function dragMouseDown(e) {
    e = e || window.event;
    e.preventDefault();

    pos3 = e.clientX;
    pos4 = e.clientY;
    document.onmouseup = closeDragElement;
    document.onmousemove = elementDrag;
  }

  function elementDrag(e) {
    e = e || window.event;
    e.preventDefault();

    pos1 = pos3 - e.clientX;
    pos2 = pos4 - e.clientY;
    pos3 = e.clientX;
    pos4 = e.clientY;

    elmnt.style.opacity = "0.8"

    elmnt.style.top = (elmnt.offsetTop - pos2) + "px";
    elmnt.style.left = (elmnt.offsetLeft - pos1) + "px";
  }

  function closeDragElement() {
    elmnt.style.opacity = "1"
    document.onmouseup = null;
    document.onmousemove = null;
  }
}

function elementsOverlap(el1, el2) {
  const domRect1 = el1.getBoundingClientRect();
  const domRect2 = el2.getBoundingClientRect();

  return !(
    domRect1.top+50 > domRect2.bottom ||
    domRect1.right-50 < domRect2.left ||
    domRect1.bottom-50 < domRect2.top ||
    domRect1.left+50 > domRect2.right
  );
}

function GetTime(createdtime){
  let time = Math.round(Date.now() / (1000 * 60)) - createdtime
  return time
}

function fancyTimeFormat(duration)
{   
    var hrs = ~~(duration / 3600);
    var mins = ~~((duration % 3600) / 60);
    var secs = ~~duration % 60;

    var ret = "";

    if (hrs > 0) {
        ret += "" + hrs + ":" + (mins < 10 ? "0" : "");
    }

    ret += "" + mins + ":" + (secs < 10 ? "0" : "");
    ret += "" + secs;
    return ret;
}
