#include "script_component.hpp"
/*
 * Author: jokoho482
 * Search pattern. Makes the unit rush and assault hostile players with range
 *
 * Arguments:
 * TODO
 *
 * Return Value:
 * TODO
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
        if (is3DEN) exitWith {};
        _input params [["_logic", objNull, [objNull]], ["_isActivated", true, [true]], ["_isCuratorPlaced", false, [true]]];
        if !(_isActivated && local _logic) exitWith {};
        if (_isCuratorPlaced) then {
            //--- Get unit under cursor
            private _group = GET_CURATOR_GRP_UNDER_CURSOR;

            //--- Check if the unit is suitable
            private _error = "";
            if (isNull _group) then {
                _error = "No Unit Seleted";
            };

            if (_error == "") then {
                ["Task Rush",
                    [
                        ["Radius", "NUMBER", "Distance rushing group will search for enemies.\nThis module only targets enemy players", 1000],
                        ["Script interval", "NUMBER", "The cycle time for the script in seconds. Higher numbers can be used to make rushers less accurate\nDefault 4 seconds", 4],
                        ["Use Group As Center", "BOOLEAN", "The rushing group will use the group leader as a center for the search pattern. Disable to have the unit use the module position instead", true]
                    ], {
                        params ["_data", "_args"];
                        _args params ["_group", "_logic"];
                        _data params ["_range", "_cycle", "_movingCenter"];
                        if (_movingCenter) then {
                            [_group, _range, _cycle] spawn FUNC(taskRush);
                        } else {
                            [_group, _range, _cycle, [], getPos _logic] spawn FUNC(taskRush);
                        };
                        deleteVehicle _logic;
                    }, {
                        params ["", "_logic"];
                        deleteVehicle _logic;
                    }, {
                        params ["", "_logic"];
                        deleteVehicle _logic;
                    }, [_group, _logic]
                ] call EFUNC(main,showDialog);
            } else {
                [objNull, _error] call BIS_fnc_showCuratorFeedbackMessage;
                deleteVehicle _logic;
            };
        } else {
            private _groups = synchronizedObjects _logic apply {group _x};
            _groups = _groups arrayIntersect _groups;

            private _area = _logic getVariable ["objectarea",[]];
            private _range = _area select ((_area select 0) < (_area select 1));
            private _cycle = _logic getVariable [QGVAR(CycleTime), 4];
            private _movingCenter = _logic getVariable [QGVAR(MovingCenter), true];

            {
                if (_movingCenter) then {
                    [_x, _range, _cycle, _area] spawn FUNC(taskRush);
                } else {
                    [_x, _range, _cycle, _area, getPos _logic] spawn FUNC(taskRush);
                };
            } forEach _groups;
            deleteVehicle _logic;
        };
    };
};
true
