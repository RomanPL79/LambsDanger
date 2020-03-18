#include "script_component.hpp"
/*
 * Author: jokoho482, nkenny
 * Resets all unit orders
 *
 * Arguments:
 * 0: Unit being reset <OBJECT> or <GROUP>
 *
 * Return Value:
 * none
 *
 * Example:
 * TODO
 *
 * Public: No
*/

params [["_mode", "", [""]], ["_input", [], [[]]]];

switch (_mode) do {
    // Default object init
    case "init": {
        if !(_isActivated && local _logic) exitWith {};
        _input params [["_logic", objNull, [objNull]], ["_isActivated", true, [true]], ["_isCuratorPlaced", false, [true]]];
        if (_isCuratorPlaced) then {

            // grabs unit under cursor
            private _group = GET_CURATOR_UNIT_UNDER_CURSOR;

            //--- Check if the unit is suitable
            private _error = "";
            if (isNull _group) then {
                _error = "No Unit Seleted";
            };

            // resets unit
            if (_error isEqualTo "") then {
                if (_group isEqualType objNull) then { _group = group _group; };
                [objNull, format ["%1 reset", groupId _group]] call BIS_fnc_showCuratorFeedbackMessage;
                [_group] call FUNC(taskReset);

            // display error
            } else {
                [objNull, _error] call BIS_fnc_showCuratorFeedbackMessage;
            };

            // clean up
            deleteVehicle _logic;
        } else {
            private _groups = synchronizedObjects _logic apply {group _x};
            _groups = _groups arrayIntersect _groups;
            {
                [_x] call FUNC(taskReset);
            } forEach _groups;
        };
    };
};
true
