// GENERATED AUTOMATICALLY FROM 'Assets/Scripts/Input/GameInput.inputactions'

using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine.InputSystem;
using UnityEngine.InputSystem.Utilities;

public class @GameInput : IInputActionCollection, IDisposable
{
    public InputActionAsset asset { get; }
    public @GameInput()
    {
        asset = InputActionAsset.FromJson(@"{
    ""name"": ""GameInput"",
    ""maps"": [
        {
            ""name"": ""Camera"",
            ""id"": ""f4e15cea-2b9e-4021-bc08-a8f67d5d011e"",
            ""actions"": [
                {
                    ""name"": ""Rotate Camera"",
                    ""type"": ""Value"",
                    ""id"": ""f693e0d8-6976-4118-b5ee-51d04f87f76a"",
                    ""expectedControlType"": ""Axis"",
                    ""processors"": """",
                    ""interactions"": """"
                },
                {
                    ""name"": ""MoveCamera"",
                    ""type"": ""Value"",
                    ""id"": ""c75d6844-8713-49a5-8f58-8519b0113383"",
                    ""expectedControlType"": ""Vector2"",
                    ""processors"": """",
                    ""interactions"": """"
                },
                {
                    ""name"": ""Scroll"",
                    ""type"": ""PassThrough"",
                    ""id"": ""c2b2656a-749d-4424-888e-86085de6dbc6"",
                    ""expectedControlType"": ""Axis"",
                    ""processors"": """",
                    ""interactions"": """"
                }
            ],
            ""bindings"": [
                {
                    ""name"": ""1D Axis"",
                    ""id"": ""b7aa0f77-bf1d-430a-a711-835a1e831869"",
                    ""path"": ""1DAxis"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Rotate Camera"",
                    ""isComposite"": true,
                    ""isPartOfComposite"": false
                },
                {
                    ""name"": ""positive"",
                    ""id"": ""4ef0b50f-0ad2-4a7a-9607-df94746d0ff3"",
                    ""path"": ""<Keyboard>/q"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Rotate Camera"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": true
                },
                {
                    ""name"": ""negative"",
                    ""id"": ""4aea5a79-6a3a-494e-b98e-6ac33484dbd6"",
                    ""path"": ""<Keyboard>/e"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Rotate Camera"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": true
                },
                {
                    ""name"": ""2D Vector"",
                    ""id"": ""afa4c677-85df-4766-81a6-0896d9f3b767"",
                    ""path"": ""2DVector"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""MoveCamera"",
                    ""isComposite"": true,
                    ""isPartOfComposite"": false
                },
                {
                    ""name"": ""up"",
                    ""id"": ""0f56d0c2-a34f-4c9d-b464-e028c9df6934"",
                    ""path"": ""<Keyboard>/w"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""MoveCamera"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": true
                },
                {
                    ""name"": ""down"",
                    ""id"": ""5d4dfb70-75d1-42df-8ebf-99fe0120c01b"",
                    ""path"": ""<Keyboard>/s"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""MoveCamera"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": true
                },
                {
                    ""name"": ""left"",
                    ""id"": ""84a5385a-5221-48e9-8c36-3d2c549fa28f"",
                    ""path"": ""<Keyboard>/a"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""MoveCamera"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": true
                },
                {
                    ""name"": ""right"",
                    ""id"": ""224c81d9-7541-4ea9-90aa-de04af83c8ff"",
                    ""path"": ""<Keyboard>/d"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""MoveCamera"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": true
                },
                {
                    ""name"": """",
                    ""id"": ""6eb1f931-c34d-4842-9310-191a20df7341"",
                    ""path"": ""<Mouse>/scroll/y"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Scroll"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false
                }
            ]
        },
        {
            ""name"": ""Game"",
            ""id"": ""74b3a98d-fe4c-4bd5-9f89-41f99285bdde"",
            ""actions"": [
                {
                    ""name"": ""Execute Steps"",
                    ""type"": ""Button"",
                    ""id"": ""29e78359-eca7-495a-9ad0-5086703e7f76"",
                    ""expectedControlType"": ""Button"",
                    ""processors"": """",
                    ""interactions"": """"
                },
                {
                    ""name"": ""Reset Steps On Selected Unit"",
                    ""type"": ""Button"",
                    ""id"": ""3934213e-dc5b-411e-a9af-86cf561e06bc"",
                    ""expectedControlType"": ""Button"",
                    ""processors"": """",
                    ""interactions"": """"
                },
                {
                    ""name"": ""Reset Steps"",
                    ""type"": ""Button"",
                    ""id"": ""d845f358-7b2f-4da5-bf46-559e0d6dd9b9"",
                    ""expectedControlType"": ""Button"",
                    ""processors"": """",
                    ""interactions"": """"
                },
                {
                    ""name"": ""NextUnit"",
                    ""type"": ""Button"",
                    ""id"": ""b9ae8fb6-df5c-48b6-9cb0-181e37b9ed90"",
                    ""expectedControlType"": ""Button"",
                    ""processors"": """",
                    ""interactions"": """"
                }
            ],
            ""bindings"": [
                {
                    ""name"": """",
                    ""id"": ""4f3bc808-9389-403f-b9ca-9e9eb51c7653"",
                    ""path"": ""<Keyboard>/space"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Execute Steps"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false
                },
                {
                    ""name"": """",
                    ""id"": ""c49d5a1d-8a2a-43a1-ba14-d9796202b2d0"",
                    ""path"": ""<Keyboard>/x"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Reset Steps On Selected Unit"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false
                },
                {
                    ""name"": """",
                    ""id"": ""f381c9b0-ac8a-4f9b-a192-a5389696572d"",
                    ""path"": ""<Keyboard>/tab"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""NextUnit"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false
                },
                {
                    ""name"": """",
                    ""id"": ""71b5ae8e-482b-4ae3-9ab9-cff82a687e99"",
                    ""path"": """",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Reset Steps"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false
                }
            ]
        }
    ],
    ""controlSchemes"": []
}");
        // Camera
        m_Camera = asset.FindActionMap("Camera", throwIfNotFound: true);
        m_Camera_RotateCamera = m_Camera.FindAction("Rotate Camera", throwIfNotFound: true);
        m_Camera_MoveCamera = m_Camera.FindAction("MoveCamera", throwIfNotFound: true);
        m_Camera_Scroll = m_Camera.FindAction("Scroll", throwIfNotFound: true);
        // Game
        m_Game = asset.FindActionMap("Game", throwIfNotFound: true);
        m_Game_ExecuteSteps = m_Game.FindAction("Execute Steps", throwIfNotFound: true);
        m_Game_ResetStepsOnSelectedUnit = m_Game.FindAction("Reset Steps On Selected Unit", throwIfNotFound: true);
        m_Game_ResetSteps = m_Game.FindAction("Reset Steps", throwIfNotFound: true);
        m_Game_NextUnit = m_Game.FindAction("NextUnit", throwIfNotFound: true);
    }

    public void Dispose()
    {
        UnityEngine.Object.Destroy(asset);
    }

    public InputBinding? bindingMask
    {
        get => asset.bindingMask;
        set => asset.bindingMask = value;
    }

    public ReadOnlyArray<InputDevice>? devices
    {
        get => asset.devices;
        set => asset.devices = value;
    }

    public ReadOnlyArray<InputControlScheme> controlSchemes => asset.controlSchemes;

    public bool Contains(InputAction action)
    {
        return asset.Contains(action);
    }

    public IEnumerator<InputAction> GetEnumerator()
    {
        return asset.GetEnumerator();
    }

    IEnumerator IEnumerable.GetEnumerator()
    {
        return GetEnumerator();
    }

    public void Enable()
    {
        asset.Enable();
    }

    public void Disable()
    {
        asset.Disable();
    }

    // Camera
    private readonly InputActionMap m_Camera;
    private ICameraActions m_CameraActionsCallbackInterface;
    private readonly InputAction m_Camera_RotateCamera;
    private readonly InputAction m_Camera_MoveCamera;
    private readonly InputAction m_Camera_Scroll;
    public struct CameraActions
    {
        private @GameInput m_Wrapper;
        public CameraActions(@GameInput wrapper) { m_Wrapper = wrapper; }
        public InputAction @RotateCamera => m_Wrapper.m_Camera_RotateCamera;
        public InputAction @MoveCamera => m_Wrapper.m_Camera_MoveCamera;
        public InputAction @Scroll => m_Wrapper.m_Camera_Scroll;
        public InputActionMap Get() { return m_Wrapper.m_Camera; }
        public void Enable() { Get().Enable(); }
        public void Disable() { Get().Disable(); }
        public bool enabled => Get().enabled;
        public static implicit operator InputActionMap(CameraActions set) { return set.Get(); }
        public void SetCallbacks(ICameraActions instance)
        {
            if (m_Wrapper.m_CameraActionsCallbackInterface != null)
            {
                @RotateCamera.started -= m_Wrapper.m_CameraActionsCallbackInterface.OnRotateCamera;
                @RotateCamera.performed -= m_Wrapper.m_CameraActionsCallbackInterface.OnRotateCamera;
                @RotateCamera.canceled -= m_Wrapper.m_CameraActionsCallbackInterface.OnRotateCamera;
                @MoveCamera.started -= m_Wrapper.m_CameraActionsCallbackInterface.OnMoveCamera;
                @MoveCamera.performed -= m_Wrapper.m_CameraActionsCallbackInterface.OnMoveCamera;
                @MoveCamera.canceled -= m_Wrapper.m_CameraActionsCallbackInterface.OnMoveCamera;
                @Scroll.started -= m_Wrapper.m_CameraActionsCallbackInterface.OnScroll;
                @Scroll.performed -= m_Wrapper.m_CameraActionsCallbackInterface.OnScroll;
                @Scroll.canceled -= m_Wrapper.m_CameraActionsCallbackInterface.OnScroll;
            }
            m_Wrapper.m_CameraActionsCallbackInterface = instance;
            if (instance != null)
            {
                @RotateCamera.started += instance.OnRotateCamera;
                @RotateCamera.performed += instance.OnRotateCamera;
                @RotateCamera.canceled += instance.OnRotateCamera;
                @MoveCamera.started += instance.OnMoveCamera;
                @MoveCamera.performed += instance.OnMoveCamera;
                @MoveCamera.canceled += instance.OnMoveCamera;
                @Scroll.started += instance.OnScroll;
                @Scroll.performed += instance.OnScroll;
                @Scroll.canceled += instance.OnScroll;
            }
        }
    }
    public CameraActions @Camera => new CameraActions(this);

    // Game
    private readonly InputActionMap m_Game;
    private IGameActions m_GameActionsCallbackInterface;
    private readonly InputAction m_Game_ExecuteSteps;
    private readonly InputAction m_Game_ResetStepsOnSelectedUnit;
    private readonly InputAction m_Game_ResetSteps;
    private readonly InputAction m_Game_NextUnit;
    public struct GameActions
    {
        private @GameInput m_Wrapper;
        public GameActions(@GameInput wrapper) { m_Wrapper = wrapper; }
        public InputAction @ExecuteSteps => m_Wrapper.m_Game_ExecuteSteps;
        public InputAction @ResetStepsOnSelectedUnit => m_Wrapper.m_Game_ResetStepsOnSelectedUnit;
        public InputAction @ResetSteps => m_Wrapper.m_Game_ResetSteps;
        public InputAction @NextUnit => m_Wrapper.m_Game_NextUnit;
        public InputActionMap Get() { return m_Wrapper.m_Game; }
        public void Enable() { Get().Enable(); }
        public void Disable() { Get().Disable(); }
        public bool enabled => Get().enabled;
        public static implicit operator InputActionMap(GameActions set) { return set.Get(); }
        public void SetCallbacks(IGameActions instance)
        {
            if (m_Wrapper.m_GameActionsCallbackInterface != null)
            {
                @ExecuteSteps.started -= m_Wrapper.m_GameActionsCallbackInterface.OnExecuteSteps;
                @ExecuteSteps.performed -= m_Wrapper.m_GameActionsCallbackInterface.OnExecuteSteps;
                @ExecuteSteps.canceled -= m_Wrapper.m_GameActionsCallbackInterface.OnExecuteSteps;
                @ResetStepsOnSelectedUnit.started -= m_Wrapper.m_GameActionsCallbackInterface.OnResetStepsOnSelectedUnit;
                @ResetStepsOnSelectedUnit.performed -= m_Wrapper.m_GameActionsCallbackInterface.OnResetStepsOnSelectedUnit;
                @ResetStepsOnSelectedUnit.canceled -= m_Wrapper.m_GameActionsCallbackInterface.OnResetStepsOnSelectedUnit;
                @ResetSteps.started -= m_Wrapper.m_GameActionsCallbackInterface.OnResetSteps;
                @ResetSteps.performed -= m_Wrapper.m_GameActionsCallbackInterface.OnResetSteps;
                @ResetSteps.canceled -= m_Wrapper.m_GameActionsCallbackInterface.OnResetSteps;
                @NextUnit.started -= m_Wrapper.m_GameActionsCallbackInterface.OnNextUnit;
                @NextUnit.performed -= m_Wrapper.m_GameActionsCallbackInterface.OnNextUnit;
                @NextUnit.canceled -= m_Wrapper.m_GameActionsCallbackInterface.OnNextUnit;
            }
            m_Wrapper.m_GameActionsCallbackInterface = instance;
            if (instance != null)
            {
                @ExecuteSteps.started += instance.OnExecuteSteps;
                @ExecuteSteps.performed += instance.OnExecuteSteps;
                @ExecuteSteps.canceled += instance.OnExecuteSteps;
                @ResetStepsOnSelectedUnit.started += instance.OnResetStepsOnSelectedUnit;
                @ResetStepsOnSelectedUnit.performed += instance.OnResetStepsOnSelectedUnit;
                @ResetStepsOnSelectedUnit.canceled += instance.OnResetStepsOnSelectedUnit;
                @ResetSteps.started += instance.OnResetSteps;
                @ResetSteps.performed += instance.OnResetSteps;
                @ResetSteps.canceled += instance.OnResetSteps;
                @NextUnit.started += instance.OnNextUnit;
                @NextUnit.performed += instance.OnNextUnit;
                @NextUnit.canceled += instance.OnNextUnit;
            }
        }
    }
    public GameActions @Game => new GameActions(this);
    public interface ICameraActions
    {
        void OnRotateCamera(InputAction.CallbackContext context);
        void OnMoveCamera(InputAction.CallbackContext context);
        void OnScroll(InputAction.CallbackContext context);
    }
    public interface IGameActions
    {
        void OnExecuteSteps(InputAction.CallbackContext context);
        void OnResetStepsOnSelectedUnit(InputAction.CallbackContext context);
        void OnResetSteps(InputAction.CallbackContext context);
        void OnNextUnit(InputAction.CallbackContext context);
    }
}
