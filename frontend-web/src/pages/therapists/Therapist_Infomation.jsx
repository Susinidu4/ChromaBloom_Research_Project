import React, { useState, useEffect } from 'react';
import { useParams } from 'react-router-dom';
import AdminLayout from '../admin/Admin_Management/AdminLayout';
import { getTherapistByIdService, updateTherapistAccountStatus } from '../../services/therapistService';
import Swal from 'sweetalert2';

export const Therapist_Infomation = () => {
    const { id } = useParams();
    const [therapist, setTherapist] = useState(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);

    useEffect(() => {
        const fetchTherapistData = async () => {
            try {
                const token = localStorage.getItem('token');
                const data = await getTherapistByIdService(id, token);
                setTherapist(data);
            } catch (err) {
                setError(err.response?.data?.message || 'Failed to fetch therapist information');
            } finally {
                setLoading(false);
            }
        };

        fetchTherapistData();
    }, [id]);

    const formatDate = (dateString) => {
        if (!dateString) return '-';
        return new Date(dateString).toLocaleDateString('en-US', {
            month: 'numeric',
            day: 'numeric',
            year: 'numeric'
        });
    };

    const handleStatusToggle = async () => {
        const newStatus = therapist.account_status === 'active' ? 'disabled' : 'active';
        const actionText = newStatus === 'active' ? 'Enable' : 'Disable';

        const result = await Swal.fire({
            title: 'Are you sure?',
            text: `Do you want to ${actionText.toLowerCase()} this therapist account?`,
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: newStatus === 'active' ? '#16a34a' : '#5C1B11',
            cancelButtonColor: '#6e7881',
            confirmButtonText: `Yes, ${actionText} it!`
        });

        if (result.isConfirmed) {
            try {
                const token = localStorage.getItem('token');
                await updateTherapistAccountStatus(id, newStatus, token);
                setTherapist({ ...therapist, account_status: newStatus });
                Swal.fire({
                    title: 'Success!',
                    text: `Therapist account has been ${newStatus === 'active' ? 'enabled' : 'disabled'}.`,
                    icon: 'success',
                    confirmButtonColor: '#BD9A6B'
                });
            } catch (err) {
                Swal.fire('Error', 'Failed to update account status', 'error');
            }
        }
    };

    if (loading) {
        return (
            <AdminLayout>
                <div className="min-h-screen bg-[#F8EBE8] flex justify-center items-center">
                    <div className="text-lg text-[#8D6E63] animate-pulse">Loading therapist details...</div>
                </div>
            </AdminLayout>
        );
    }

    if (error) {
        return (
            <AdminLayout>
                <div className="min-h-screen bg-[#F8EBE8] flex justify-center items-center">
                    <div className="text-lg text-red-600 bg-white p-6 rounded-lg shadow-sm border border-red-100">{error}</div>
                </div>
            </AdminLayout>
        );
    }

    if (!therapist) {
        return (
            <AdminLayout>
                <div className="min-h-screen bg-[#F8EBE8] flex justify-center items-center">
                    <div className="text-lg text-[#8D6E63]">No therapist data found</div>
                </div>
            </AdminLayout>
        );
    }

    // Info row component
    const InfoRow = ({ label, value }) => (
        <div className="grid grid-cols-[180px_20px_1fr] items-baseline mb-4">
            <span className="text-[#A68972] text-[15px] font-medium">{label}</span>
            <span className="text-[#A68972] text-[15px]">:</span>
            <div className="border-b border-[#DBC7B8] pb-1">
                <span className="text-[#7A5C41] text-[15px] ml-1">{value || '-'}</span>
            </div>
        </div>
    );

    // Section header component
    const SectionHeader = ({ title }) => (
        <div className="mb-6">
            <div className="flex items-center justify-between pb-1">
                <h3 className="text-[#8D6E63] font-bold text-[18px] tracking-tight">{title}</h3>
                <svg className="w-6 h-6 text-[#A68972]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M19 9l-7 7-7-7" />
                </svg>
            </div>
            <div className="border-b border-[#DBC7B8]"></div>
        </div>
    );

    return (
        <AdminLayout>
            <div className="min-h-screen bg-[#F8EBE8] flex flex-col items-center py-12 px-4 relative font-sans">

                {/* Back Button */}
                <button
                    className="absolute top-8 left-8 w-10 h-10 rounded-full bg-white shadow-[0_2px_10px_rgba(0,0,0,0.1)] flex items-center justify-center text-[#B08968] hover:bg-gray-50 transition-all hover:scale-105 z-10"
                    onClick={() => window.history.back()}
                >
                    <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M15 19l-7-7 7-7" />
                    </svg>
                </button>

                <div className="w-full max-w-3xl bg-[#FCF6F4]/50 backdrop-blur-sm border border-[#E6D5C7] rounded-[20px] p-10 mt-4 shadow-sm">

                    {/* Professional Information Section */}
                    <div className="mb-10">
                        <SectionHeader title="Professional Information" />
                        <div className="pl-6">
                            <InfoRow label="Specialization" value={therapist.specialization} />
                            <InfoRow label="Licence Number" value={therapist.licence_number} />
                            <InfoRow label="Work Place" value={therapist.work_place} />
                            <InfoRow label="Experience Since" value={formatDate(therapist.start_date)} />
                        </div>
                    </div>

                    {/* Personal Information Section */}
                    <div className="mb-10">
                        <SectionHeader title="Personal Information" />
                        <div className="pl-6">
                            <InfoRow label="Full Name" value={therapist.full_name} />
                            <InfoRow label="Gender" value={therapist.gender} />
                            <InfoRow label="Date of Birth" value={formatDate(therapist.dob)} />
                        </div>
                    </div>

                    {/* Contact Information Section */}
                    <div className="mb-10">
                        <SectionHeader title="Contact Information" />
                        <div className="pl-6">
                            <InfoRow label="Email Address" value={therapist.email} />
                            <InfoRow label="Phone Number" value={therapist.phone} />
                            <InfoRow label="Home Address" value={therapist.address} />
                        </div>
                    </div>

                    {/* Account Status / Other Section */}
                    <div className="mb-6">
                        <SectionHeader title="Other Information" />
                        <div className="pl-6">
                            <InfoRow label="Therapist ID" value={therapist._id} />
                            <InfoRow label="Created Date" value={formatDate(therapist.createdAt)} />
                            <InfoRow label="Last Updated On" value={formatDate(therapist.updatedAt)} />
                        </div>
                    </div>

                </div>

                {/* Action Button */}
                <div className="w-full max-w-3xl flex justify-end mt-8">
                    <button
                        className={`${therapist.account_status === 'active'
                                ? 'bg-[#5C1B11] shadow-[0_4px_12px_rgba(92,27,17,0.3)] hover:bg-[#4a160d]'
                                : 'bg-green-700 shadow-[0_4px_12px_rgba(21,128,61,0.3)] hover:bg-green-800'
                            } text-white px-10 py-3 rounded-xl font-semibold text-sm transition-all active:scale-95`}
                        onClick={handleStatusToggle}
                    >
                        {therapist.account_status === 'active' ? 'Disable Therapist' : 'Enable Therapist'}
                    </button>
                </div>

            </div>
        </AdminLayout>
    );
};
