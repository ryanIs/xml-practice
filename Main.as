/*
	XMLPractice
	by Ryan Isler
	12/8/13
*/
package {
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	/*
	public function typeMessage(_message:String):void { //set up variable package var variables:URLVariables = new URLVariables(); //set up target url, method top, and data var varSend:URLRequest = new URLRequest("addToChat.php"); varSend.method = URLRequestMethod.POST; varSend.data = variables; // var varLoader:URLLoader = new URLLoader; varLoader.dataFormat = URLLoaderDataFormat.VARIABLES; varLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError, false, 0, true); varLoader.addEventListener(Event.COMPLETE, recieveData); variables.mess = userName + ": " + _message; variables.sendRequest = "parse"; varLoader.load(varSend); } public function recieveData(event:Event):void { var loader:URLLoader = URLLoader(event.target); var vars:URLVariables = new URLVariables(loader.data); }
	*/
	public class Main extends MovieClip {
		
		public var mainMenu:ContextMenu;
		public var infoDisplayTemp:Array = new Array(16);
		public var infoDisplayStage:Number = 0; // 0 = Not displaying, 1 = gradually remove, 2 = gradually show, 3 = Currently displaying
		public var displayStage:Number = 0; // 0 = Not displaying, 1 = gradually remove them, 2 = gradually show them, 3 = Currently displaying
		public var viewIndex:Number = 0;
		public var viewIndexMax:Number = 0; // Number of extra sets of 8 buttons.
		public var displayApplicants:Number = 0;
		public var totalApplicants:Number = 0;
		public var applicants:Array = new Array();
		public var applicantsXML:XML;
		public const XMLFile:String = "./applicants.xml";
		public var XMLLoader:URLLoader = new URLLoader();
		
		public const FPS:Number = 60.00;
		private var i:Number = 0;
		
		public function Main() {
			stop();
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		public function enterFrameHandler(e:Event):void {
			if(infoDisplayStage == 1) {
				if(information_mc.alpha > 0) {
					information_mc.alpha -= 0.02;
				}
				if(information_mc.alpha < 0.01) {
					infoDisplayStage = 0;
					displayInformation(infoDisplayTemp[0], infoDisplayTemp[1], infoDisplayTemp[2], infoDisplayTemp[3], infoDisplayTemp[4]);
				}
			} else if(infoDisplayStage == 2) {
				if(information_mc.alpha < 1) {
					information_mc.alpha += 0.02;
				}
				if(information_mc.alpha > 0.99) {
					infoDisplayStage = 3;
				}
			}
			if(displayStage == 1) {
				if(b0.alpha > 0) {
					for(i = 0; i < displayApplicants; i++) {
						this["b" + i].alpha -= 0.02;
					}
					s0.alpha -= 0.02;
					s1.alpha -= 0.02;
				}
				if(selected_mc.alpha > 0) {
					selected_mc.alpha -= 0.02;
				}
				if(b0.alpha < 0.01) {
					displayStage = 0;
					displayButtons();
				}
			} else if(displayStage == 2) {
				if(b0.alpha < 1) {
					for(i = 0; i < displayApplicants; i++) {
						this["b" + i].alpha += 0.02;
					}
					s0.alpha += 0.02;
					s1.alpha += 0.02;
				}
				if(selected_mc.alpha < 1) {
					selected_mc.alpha += 0.02;
				}
			} else if(displayStage == 3) {
				if(selected_mc.alpha < 1) {
					selected_mc.alpha += 0.02;
				}
			}
			if(viewIndexMax > 0) {
				var _gotoX:Number = ((viewIndex) * applicantsBar_mc.bar_mc.width);
				applicantsBar_mc.bar_mc.x += (_gotoX - applicantsBar_mc.bar_mc.x) / 10;
			}
			return;
		}
		public function displayInformation(_name:String, _age:Number, _address:String, _bio:String, _occ:String):void {
			if(infoDisplayStage != 1 && infoDisplayStage != 2) { // If not gradually removing, or gradually displaying
				if(infoDisplayStage == 0) {  // Already not up. (prefered)
					information_mc.alpha = 0;
					infoDisplayStage = 2;
					information_mc.name_txt.text = _name;
					information_mc.age_txt.text = "Age: " + _age.toString();
					information_mc.address_txt.text = _address;
					information_mc.bio_txt.text = "Biography: " + _bio;
					information_mc.occupation_txt.text = _occ;
				} else if(infoDisplayStage == 3) { // Already up. (remove it)
					infoDisplayStage = 1;
					infoDisplayTemp[0] = new String(_name);
					infoDisplayTemp[1] = new Number(_age);
					infoDisplayTemp[2] = new String(_address)
					infoDisplayTemp[3] = new String(_bio);
					infoDisplayTemp[4] = new String(_occ);
				}
			}
			return;
		}
		public function applicantButtonClick(e:MouseEvent):void {
			//trace(e.currentTarget.name + " " + e.currentTarget.applicantID);
			if(infoDisplayStage != 2 && infoDisplayStage != 1) {
				selected_mc.x = e.currentTarget.x;
				selected_mc.y = e.currentTarget.y;
				selected_mc.alpha = 0;
			}
			displayInformation(applicants[e.currentTarget.applicantID].name, applicants[e.currentTarget.applicantID].age, applicants[e.currentTarget.applicantID].address, applicants[e.currentTarget.applicantID].biography, applicants[e.currentTarget.applicantID].occupation);
			e.currentTarget.gotoAndStop(1);
			return;
		}
		public function displayButtons():void {
			selected_mc.y = -200;
			left_btn.visible = true;
			right_btn.visible = true;
			if(viewIndex == 0) {
				left_btn.visible = false;
			}
			if(viewIndex == viewIndexMax) {
				right_btn.visible = false;
			}
			if(totalApplicants > 0) {
				if(viewIndexMax == 0) {
					displayApplicants = totalApplicants;
				} else {
					if(viewIndex < viewIndexMax) {
						displayApplicants = 8;
					} else {
						displayApplicants = totalApplicants - (8 * viewIndex);
					}
				}
				s0.alpha = 0;
				s1.alpha = 0; 
				s1.x = this["b" + (displayApplicants-1)].x + 46.10;
				for(i = 0; i < displayApplicants; i++) { //trace(i + (8 * viewIndex));
					 this["b" + i].alpha = 0; //trace(viewIndex);
					 this["b" + i].applicantID = i + (8 * viewIndex);
					 this["b" + i].name_txt.text = applicants[i + (8 * viewIndex)].name;
					 this["b" + i].addEventListener(MouseEvent.CLICK, applicantButtonClick);
				}
				displayStage = 2;
				//if(b0.alpha < 0.01) {
					//displayStage = 2;
				//}
			} else {
				message_txt.text = "No applicants found.";
				//applicantsBar_mc.bar_mc.width = 0;
			}
			return;
		}
		public function XMLLoaderComplete(e:Event):void {
			applicantsXML = new XML(e.target.data);
			applicantsXML.ignoreWhitespace = true;
			i = 0;
			while(applicantsXML.applicant[i] != null) {
				var newApp:Object = new Object();
				newApp.name = applicantsXML.applicant[i].name;
				newApp.middleName = applicantsXML.applicant[i].name.attribute("middle");
				newApp.lastName = applicantsXML.applicant[i].name.attribute("last");
				newApp.age = applicantsXML.applicant[i].age;
				newApp.address = applicantsXML.applicant[i].address;
				newApp.occupation = applicantsXML.applicant[i].occupation;
				newApp.biography = applicantsXML.applicant[i].bio;
				applicants.push(newApp);
				i++;
			}
			totalApplicants = i;
			message_txt.text = "";
			viewIndexMax = Math.floor((totalApplicants-1) / 8);
			if(viewIndexMax < 0) {
				applicantsBar_mc.bar_mc.width = 0;
				viewIndexMax = 0;
			}
			else
			applicantsBar_mc.bar_mc.width = (1 / (viewIndexMax + 1)) * 760;
			displayButtons();
			return;
		}
		public function XMLLoaderIOError(e:IOErrorEvent):void {
			trace("Error: " + e.text);
			message_txt.text = "Error loading: \"" + XMLFile + "\"";
			return;
		}
		public function applicantButtonOver(e:MouseEvent):void {
			e.currentTarget.gotoAndStop(2);
			return;
		}
		public function applicantButtonOut(e:MouseEvent):void {
			e.currentTarget.gotoAndStop(1);
			return;
		}
		public function applicantButtonDown(e:MouseEvent):void {
			e.currentTarget.gotoAndStop(3);
			return;
		}
		public function applicantButtonUp(e:MouseEvent):void {
			e.currentTarget.gotoAndStop(1);
			return;
		}
		public function leftArrowDown(e:MouseEvent):void {
			if(displayStage != 1) {
				if(viewIndex > 0) {
					viewIndex--;
					displayStage = 1;
				}
			}
			return;
		}
		public function rightArrowDown(e:MouseEvent):void {
			if(displayStage != 1) {
				if(viewIndex < viewIndexMax) {
					viewIndex++;
					displayStage = 1;
				}
			}
			return;
		}
		public function ryanItemSelect(e:ContextMenuEvent):void {
			trace("Hello world!");
			return;
		}
		public function addedToStageHandler(e:Event):void {
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			XMLLoader.addEventListener(IOErrorEvent.IO_ERROR, XMLLoaderIOError);
			XMLLoader.addEventListener(Event.COMPLETE, XMLLoaderComplete);
			XMLLoader.load(new URLRequest(XMLFile));
			message_txt.text = "Loading \"" + XMLFile + "\" file...";
			for(i = 0; i < 8; i++) {
				this["b" + i].alpha = 0;
				this["b" + i].addEventListener(MouseEvent.MOUSE_OVER, applicantButtonOver);
				this["b" + i].addEventListener(MouseEvent.MOUSE_OUT, applicantButtonUp);
				this["b" + i].addEventListener(MouseEvent.MOUSE_DOWN, applicantButtonDown);
				this["b" + i].addEventListener(MouseEvent.MOUSE_UP, applicantButtonDown);
			}
			left_btn.addEventListener(MouseEvent.CLICK, leftArrowDown);
			right_btn.addEventListener(MouseEvent.CLICK, rightArrowDown);
			information_mc.alpha = 0;
			s0.alpha = s1.alpha = 0;
			left_btn.visible = right_btn.visible = false;
			
			mainMenu = new ContextMenu();
			mainMenu.builtInItems.loop = false;
			mainMenu.builtInItems.play = false;
			mainMenu.builtInItems.rewind = false;
			mainMenu.builtInItems.zoom = false;
			mainMenu.builtInItems.print = false;
			
			var ryanItem:ContextMenuItem = new ContextMenuItem("Created by Ryan Isler", true, false, true);
			ryanItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, ryanItemSelect);
			mainMenu.customItems.push(ryanItem);
			contextMenu = mainMenu;
			return;
		}
	}
}